# Doc Application (Doctor Appointment System)

## Overview
Doc Application is a full‑stack **Doctor Appointment Booking System** built using:
- **Frontend:** React.js
- **Backend:** Node.js + Express.js
- **Database:** MongoDB

The application allows users to book appointments with doctors, while doctors and admins can manage schedules, approvals, and users.

---

## Project Structure
```
DOC-APPLICTION-main/
│
├── client/                 # React frontend
│   ├── public/
│   ├── src/
│   └── package.json
│
├── routes/                 # API route definitions
├── models/                 # Mongoose models
├── controllers/            # Business logic
├── middleware/             # Auth & validation middleware
├── server.js               # Express entry point
└── README.md
```

---

## Features
### User
- Register & login
- View doctors
- Book appointments
- View appointment status

### Doctor
- Apply for doctor role
- Manage availability
- View appointments

### Admin
- Approve / reject doctors
- Manage users
- System overview

---

## Tech Stack
- **Frontend:** React, Axios, Bootstrap
- **Backend:** Node.js, Express.js
- **Database:** MongoDB (Mongoose)
- **Authentication:** JWT
- **State Management:** React hooks

---

## Prerequisites
- Node.js (v16+ recommended)
- MongoDB (local or cloud)
- npm or yarn

---

## Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/dattatray001/DOC-APPLICTION.git
cd DOC-APPLICTION-main
```

### 2. Backend Setup
```bash
npm install
npm start
```

Backend runs on:
```
http://localhost:5000
```

### 3. Frontend Setup
```bash
cd client
npm install
npm start
```

Frontend runs on:
```
http://localhost:3000
```

---

## Environment Variables
Create a `.env` file in the root directory:
```
PORT=5000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_secret_key
```

---

## API Endpoints (Sample)
- `POST /api/v1/user/login`
- `POST /api/v1/user/register`
- `POST /api/v1/doctor/apply`
- `GET  /api/v1/admin/getAllDoctors`

---

## Security
- JWT‑based authentication
- Role‑based access control
- Protected routes

---

## Future Enhancements
- Payment gateway integration
- Email/SMS notifications
- Calendar integration
- Role‑based dashboards

---

## Author
**Dattatray Narhe**  
Software Developer


