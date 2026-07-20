terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "container_app_id" {
  description = "Resource ID of the app/service whose logs should be shipped centrally"
  type        = string
}

variable "security_team_email" {
  type    = string
  default = "security-oncall@cloudeorbit.example"
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# ---------------------------------------------------------
# Centralized, encrypted log storage
# ---------------------------------------------------------

resource "azurerm_log_analytics_workspace" "law" {
  name                = "cloudeorbit-law"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  # Log Analytics encrypts data at rest by default (Microsoft-managed keys)
}

resource "azurerm_key_vault" "kv" {
  name                       = "cloudeorbit-kv"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90
}

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "storage_identity" {
  name                = "log-storage-identity"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_key_vault_access_policy" "storage_identity_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.storage_identity.principal_id

  key_permissions = ["Get", "UnwrapKey", "WrapKey"]
}

resource "azurerm_key_vault_key" "log_key" {
  name         = "log-storage-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [azurerm_key_vault_access_policy.storage_identity_policy]
}

resource "azurerm_storage_account" "log_archive" {
  name                     = "cloudeorbitlogsarchive"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.storage_identity.id]
  }

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.log_key.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_identity.id
  }
}

# ---------------------------------------------------------
# Diagnostic settings: ship security/app events to the workspace
# ---------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "app_diag" {
  name                       = "send-to-law"
  target_resource_id         = var.container_app_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "ContainerAppConsoleLogs"
  }
  enabled_log {
    category = "ContainerAppSystemLogs"
  }
  metric {
    category = "AllMetrics"
  }
}

# ---------------------------------------------------------
# Monitoring & alerting (closes "alerting_configured" gap)
# ---------------------------------------------------------

resource "azurerm_monitor_action_group" "security_team" {
  name                = "security-alerts"
  resource_group_name = data.azurerm_resource_group.rg.name
  short_name          = "secalert"

  email_receiver {
    name          = "oncall"
    email_address = var.security_team_email
  }
}

resource "azurerm_monitor_activity_log_alert" "security_alert" {
  name                = "security-events-alert"
  resource_group_name = data.azurerm_resource_group.rg.name
  scopes              = [data.azurerm_resource_group.rg.id]

  criteria {
    category = "Security"
  }

  action {
    action_group_id = azurerm_monitor_action_group.security_team.id
  }
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
}
