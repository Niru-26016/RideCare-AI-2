# 🚗 RideCare-AI

**Predictive Maintenance & Fleet Intelligence System**

RideCare-AI is a dual-platform solution designed to revolutionize fleet management by predicting vehicle failures before they happen. It combines a **Flutter-powered Driver App** with a **React-based Admin Dashboard**, all synced in real-time through **Firebase**.

![RideCare Logo](./logo.jpeg)

## 🌟 Key Features

### 📱 Driver Application (Flutter)
- **Map-Centric Interface**: Full-screen Google Maps integration with custom dark-mode aesthetics.
- **Smart "Go Online" Logic**: Safety-first approach that blocks drivers from going online if vehicle health is below 80%.
- **Interactive Telemetry**: Real-time sliders to monitor and simulate engine temperature, battery voltage, mileage, and vibrations.
- **Predictive Alerts**: Instant notifications for "Service Due Soon" or "Critical Failures" based on live sensor data.
- **Service Center Locator**: Automatically highlights nearest service centers on the map when vehicle health drops.
- **Granular Service Logging**: Log specific services (Battery Replace, Oil Change, etc.) which intelligently restore specific vehicle metrics and reset health scores.

### 🌐 Admin Dashboard (React + Vite)
- **Fleet Control Center**: At-a-glance view of the entire fleet's health index and status distribution.
- **Live Monitoring**: Real-time tracking of every vehicle's telemetry and health score trends.
- **Advanced Data Viz**: Interactive time-series charts showing health score evolution.
- **Alerts Feed**: Critical issues and predictive maintenance warnings centralized for admin action.
- **Data Export**: One-click CSV export of all fleet diagnostics for offline analysis.
- **Premium Dark UI**: Built with Tailwind CSS and Framer Motion for a sleek, glassmorphic experience.

---

## 🛠 Tech Stack

- **Mobile**: [Flutter](https://flutter.dev/) (Dart)
- **Web**: [React](https://reactjs.org/) (Vite, Tailwind CSS, Lucide Icons)
- **Backend**: [Firebase](https://firebase.google.com/) (Cloud Firestore for real-time sync)
- **Maps**: [Google Maps API](https://developers.google.com/maps)
- **AI/ML**: Predictive health scoring engine (EvaluateHealth) integrated into both apps.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest)
- Node.js (v18+)
- Google Maps API Key
- Firebase Project with Firestore enabled

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Niru-26016/RideCare-AI-2.git
   cd RideCare-AI-2
   ```

2. **Setup the Web Dashboard**
   ```bash
   cd "RideCare-AI web"
   npm install
   # Create a .env file with your Firebase config
   npm run dev
   ```

3. **Setup the Driver App**
   ```bash
   cd "RideCare-AI driver app"
   flutter pub get
   # Ensure your Google Maps API key is in AndroidManifest.xml
   flutter run
   ```

---

## 📁 System Architecture

RideCare-AI uses a **Real-Time Data Bridge** architecture:
- Both apps connect to a shared **Firestore** instance.
- **Driver App** acts as the primary data source, writing sensor telemetry and service logs.
- **Web Dashboard** acts as the monitoring and intelligence layer, consuming the live stream and calculating fleet-wide analytics.
- **Health Engine**: A unified scoring algorithm ported to both Dart and JavaScript to ensure consistent health reporting across mobile and web.

---

## 📊 Documentation & Walkthrough
Detailed implementation notes and feature breakdowns can be found in our [walkthrough guide](.gemini/antigravity/brain/6dc46640-ba37-40e8-8651-8f667cc90c2b/walkthrough.md).

---

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

---

*Built with ❤️ for the future of Fleet Management.*
