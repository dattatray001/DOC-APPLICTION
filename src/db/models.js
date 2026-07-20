const { Sequelize, DataTypes } = require("sequelize");
const sequelize = new Sequelize(process.env.DATABASE_URL);

const User = sequelize.define("User", {
  email: { type: DataTypes.STRING, unique: true },
  passwordHash: { type: DataTypes.STRING },
  role: { type: DataTypes.STRING, defaultValue: "user" }
});

// Parametrized lookup via Sequelize ORM — no raw query concatenation.
async function findUserByEmail(email) {
  return User.findOne({ where: { email } });
}

// User registration / creation logging
async function createUser(email, passwordHash, correlationId = null) {
  const user = await User.create({ email, passwordHash });
  console.log(`[${new Date().toISOString()}] [correlation_id: ${correlationId}] [INFO] Event: user_created. Created user with email: ${email}`);
  return user;
}

// User deletion logging
async function deleteUser(userId, correlationId = null) {
  const user = await User.findByPk(userId);
  if (user) {
    await user.destroy();
    console.log(`[${new Date().toISOString()}] [correlation_id: ${correlationId}] [INFO] Event: user_deleted. Deleted user ID: ${userId}`);
  }
}

// Role modification logging (privilege escalation tracking)
async function changeUserRole(userId, newRole, correlationId = null) {
  const user = await User.findByPk(userId);
  if (user) {
    const oldRole = user.role;
    user.role = newRole;
    await user.save();
    console.log(`[${new Date().toISOString()}] [correlation_id: ${correlationId}] [WARNING] Event: role_changed. Changed user ID ${userId} role from ${oldRole} to ${newRole}`);
  }
}

// User login logging
async function logUserLogin(email, success, correlationId = null) {
  if (success) {
    console.log(`[${new Date().toISOString()}] [correlation_id: ${correlationId}] [INFO] Event: login. Successful login for user: ${email}`);
  } else {
    console.log(`[${new Date().toISOString()}] [correlation_id: ${correlationId}] [WARN] Event: signin. Failed login/signin attempt for user: ${email}`);
  }
}

// User logout logging
async function logUserLogout(email, correlationId = null) {
  console.log(`[${new Date().toISOString()}] [correlation_id: ${correlationId}] [INFO] Event: logout. User logged out: ${email}`);
}

module.exports = { 
  User, 
  findUserByEmail, 
  createUser, 
  deleteUser, 
  changeUserRole, 
  logUserLogin, 
  logUserLogout 
};
