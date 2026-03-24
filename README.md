# 🧘‍♂️ SkeletonFit (Workout with AI Pose Estimation) 🏋️‍♂️

SkeletonFit is a modern workout tracking application that integrates **Pose Estimation (AI)** to provide real-time feedback and smarter workout recording. 

---

## 📂 Project Architecture
The project is structured into three distinct sub-modules:
-   **`/frontend`**: Built with **Flutter**. Handles UI, real-time camera AI, and mobile logic.
-   **`/backend`**: Powered by **Node.js & PostgreSQL**. Manages users, exercises, and workout history.
-   **`/skeleton_lib`**: A dedicated **Python AI Library** for Pose analysis and validation.

---

## 🚀 Getting Started

### 1. ⚙️ Backend Setup
- `cd backend && npm install`
- Configure **`.env`** based on **`.env.example`**
- Run: `node server.js`

### 2. 📱 Frontend Setup
- `cd frontend && flutter pub get`
- Run: `flutter run`

### 3. 🤖 AI Processing Setup
- `cd skeleton_lib`
- Install requirements and run: `python main.py`

---

## 🛡️ Security & Privacy
- Sensitive data is managed via `.env` files.
- Git is pre-configured to ignore confidential files for your protection.

---

## ✍️ Authors
- **ThanatpornMilk** (Project Creator) 🥛

---
*Developed with the assistance of Antigravity AI Coding Assistant.*