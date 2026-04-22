# Smart Clinic + 🏥

**Smart Clinic +** is a comprehensive healthcare management ecosystem designed to bridge the gap between patients, doctors, and medical facilities. It provides a seamless experience for managing medical records, booking appointments, and maintaining health history with a focus on security, scalability, and high performance.

---

## 🌐 System Ecosystem
The project is built as a multi-platform solution:
1. **Mobile Application (Flutter)**: A tailored experience for Patients and Doctors to manage health data on the go.
2. **Admin Dashboard (Web)**: A centralized control panel for clinic administrators to manage approvals, verify doctors, and oversee system oversight.
3. **Backend API (.NET Core)**: The central engine serving both the mobile and web platforms, hosted on a RESTful architecture.

---

## 🏗️ Architecture: Clean Architecture
The mobile application follows **Clean Architecture** principles to ensure the code is modular, scalable, and easy to test. This separation ensures that the business logic is independent of the UI and external frameworks.



### Layers:
* **Presentation Layer**: UI (Widgets) and state management using **BLoC/Cubit**. It only communicates with the Domain layer.
* **Domain Layer**: The heart of the app containing **Entities**, **UseCases**, and **Repository Interfaces** (Contracts).
* **Data Layer**: Responsible for data retrieval. Contains **Repository Implementations**, **Data Sources** (Retrofit for APIs, SharedPreferences for Local), and **Models** (DTOs).

---

## 🛠️ Tech Stack
* **Framework**: [Flutter](https://flutter.dev/) (v3.x)
* **Language**: [Dart](https://dart.dev/)
* **State Management**: [Flutter BLoC / Cubit](https://pub.dev/packages/flutter_bloc)
* **Networking**: [Dio](https://pub.dev/packages/dio) & [Retrofit](https://pub.dev/packages/retrofit)
* **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it)
* **Serialization**: [Json Serializable](https://pub.dev/packages/json_serializable)
* **UI Utilities**: [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil), [Dotted Border](https://pub.dev/packages/dotted_border)

---

## 🔗 Project Resources

### 🎨 Design & Prototyping
* **Figma File**: `https://www.figma.com/design/NlZxFsIXZm5DJ2SKJxewDG/SmartClinic-?node-id=0-1&t=PeenC87Vkhwyzbwm-1`
* **Color Palette**: `https://docs.google.com/spreadsheets/d/1ywAS-PmSQjxSdUCJvEzg9oAVZz9MwD4_52b1iUuq75k/edit?gid=883073812#gid=883073812`
* **UI Style Guide**: Comprehensive guide for colors, typography, and reusable components.

### 🖥️ Admin & Backend
* **Admin Website**: `[Insert Admin Website URL Here]`
* **Backend Server**: `http://smartclinicccc.runasp.net/`
* **API Documentation**: `[Insert Swagger/Postman Link Here]`

### 📚 Technical Documentation
* **Project Wiki**: `[Insert Documentation Link Here]` — Includes ERD Diagrams, System Design, and User Guides.
* **Developer Onboarding**: Detailed steps for setting up the local environment and contribution rules.

---

## ⚙️ Key Features
- [x] **Multi-Role Authentication**: Distinct registration and login flows for Patients, Doctors, and Hospitals.
- [x] **Medical Records Vault**: Securely upload and categorize lab results/prescriptions using **Multipart/Form-Data**.
- [x] **Smart Initialization**: Splash screen logic to handle session persistence, token validation, and auto-login.
- [x] **Security**: Advanced Regex-based validation for passwords (Upper, Lower, Numeric, Symbols) to match enterprise standards.
- [x] **Responsive UI**: Pixel-perfect implementation matching the Figma design across various screen sizes.

---

## 🛠️ Installation & Setup
1. **Clone the repository**:
   ```bash
   git clone [https://github.com/Dido-Tarek/smart-clinic.git](https://github.com/Dido-Tarek/smart-clinic.git)
2. **Install Dependecies**:
   ```bash
   flutter pub get
3. **Generate necessary code (Retrofit/JsonSerializable)**:
   ```bash
   flutter pub run build-runner build --delete-conflicting-outputs
4. **Run The App**:
   ```bash
   flutter run
