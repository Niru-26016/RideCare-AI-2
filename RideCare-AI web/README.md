# RideCare AI 🚗✨

**Predictive Vehicle Health Dashboard** built for modern fleet management.

RideCare AI is a real-time monitoring system that continuously tracks vehicle telemetry, predicts maintenance issues before they become critical, and flags vehicles that require attention to prevent downtime.

## 🌟 Features

- **Live Fleet Monitoring:** View active telemetry for all vehicles (Engine Temp, Battery Voltage, Vibration, Fuel Efficiency).
- **Predictive AI Insights:** Identifies potential system failures based on real-time data trends.
- **Smart Alerts:** Instant hazard notifications when a vehicle reaches critical status.
- **Driver Simulator:** Built-in driver app simulator to test automatic ride booking blocks for critically damaged vehicles.
## Architecture

## 🚀 Getting Started
<img width="2310" height="1843" alt="ridecare githuh" src="https://github.com/user-attachments/assets/aedc3b7e-9637-4018-bfa5-ff517674519d" />

### Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Firebase Account
- OpenAI API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ridecare-ai.git
   cd ridecare-ai
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up Environment Variables**
   Create a `.env` file in the root directory and add your keys:
   ```env
   VITE_FIREBASE_API_KEY=your_firebase_api_key
   VITE_FIREBASE_AUTH_DOMAIN=your_firebase_auth_domain
   VITE_FIREBASE_PROJECT_ID=your_project_id
   VITE_FIREBASE_STORAGE_BUCKET=your_storage_bucket
   VITE_FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
   VITE_FIREBASE_APP_ID=your_app_id
   VITE_OPENAI_API_KEY=your_openai_key
   ```

4. **Run the Development Server**
   ```bash
   npm run dev
   ```

## 🛠️ Tech Stack

- **Frontend:** React + Vite, TailwindCSS
- **Backend/DB:** Firebase (Firestore)
- **AI Analysis:** OpenAI GPT-4
- **Icons & UI:** Lucide React, Recharts

## 💡 Hackathon Demo Mode

The dashboard includes a built-in **Fault Injector**. You can manually trigger specific vehicle faults (e.g., Battery Failure, Overheating) from the top navigation bar to demonstrate the AI's real-time detection and block capabilities during presentations.
