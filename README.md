<div align="center">
  <a href="#english">🇬🇧 English</a> | <a href="#indonesia">🇮🇩 Indonesia</a>
</div>

---

<h1 id="english">🌿 SiHijau Pintar - Intelligent Plant Management App (English)</h1>

SiHijau Pintar is an intelligent plant management and identification app built with Flutter. It leverages Artificial Intelligence (Gemini AI) to help users identify plants from photos and manage their personal plant collection efficiently.

## ✨ Features
- **Plant Identification (AI)**: Take a photo or upload an image to identify plants and get detailed care instructions powered by Gemini AI.
- **My Plants Collection**: Save and manage your favorite plants in a personal collection.
- **History Tracking**: Keep track of your past plant scans and identifications.
- **Authentication**: Secure login and password recovery powered by Firebase Auth.
- **Cloud Storage**: Seamless image uploading utilizing Cloudinary.
- **Responsive UI**: Beautiful, dynamic interface optimized for various screen sizes using `flutter_screenutil`.

## 🛠️ Tech Stack
- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Backend & Database**: Firebase (Auth, Firestore)
- **AI Integration**: [Google Generative AI (Gemini)](https://pub.dev/packages/google_generative_ai)
- **Cloud Storage**: [Cloudinary](https://cloudinary.com/)
- **Local Storage**: Shared Preferences

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites
- Flutter SDK (v3.12.2 or higher)
- Android Studio / Xcode for emulators
- A Firebase Project
- A Cloudinary Account
- Gemini API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/sihijau_app.git
   cd sihijau_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Environment Variables**
   - Copy the `.env.example` file to create a `.env` file:
     ```bash
     cp .env.example .env
     ```
   - Open `.env` and fill in your API keys:
     ```env
     GEMINI_API_KEY=your_gemini_api_key
     CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
     CLOUDINARY_UPLOAD_PRESET=your_upload_preset
     ```

4. **Setup Firebase**
   - **Android**: Add your `google-services.json` (see `google-services.example.json` for structure) to `android/app/`.
   - **iOS**: Add your `GoogleService-Info.plist` (see `GoogleService-Info.example.plist` for structure) to `ios/Runner/`.

5. **Run the App**
   ```bash
   flutter run
   ```

## 📱 Screenshots
*(Add your app screenshots here by uploading them to an `assets/screenshots` folder and linking them like this: `![Home Screen](assets/screenshots/home.png)`)*

## 🛡️ Security
Sensitive configuration files and API keys have been secured:
- Firebase configs are excluded via `.gitignore`.
- API keys (Gemini, Cloudinary) are securely managed using `flutter_dotenv`.

---

<h1 id="indonesia">🌿 SiHijau Pintar - Aplikasi Manajemen Tanaman Cerdas (Indonesia)</h1>

SiHijau Pintar adalah aplikasi manajemen dan identifikasi tanaman cerdas yang dibangun menggunakan Flutter. Aplikasi ini memanfaatkan Kecerdasan Buatan (Gemini AI) untuk membantu pengguna mengidentifikasi tanaman dari foto dan mengelola koleksi tanaman pribadi mereka secara efisien.

## ✨ Fitur Utama
- **Identifikasi Tanaman (AI)**: Ambil foto atau unggah gambar untuk mengidentifikasi tanaman dan mendapatkan instruksi perawatan detail yang ditenagai oleh Gemini AI.
- **Koleksi Tanaman Saya**: Simpan dan kelola tanaman favorit Anda dalam koleksi pribadi.
- **Riwayat Pemindaian**: Lacak riwayat pemindaian dan identifikasi tanaman Anda sebelumnya.
- **Autentikasi**: Login aman dan pemulihan kata sandi yang ditenagai oleh Firebase Auth.
- **Penyimpanan Cloud**: Pengunggahan gambar yang lancar menggunakan layanan Cloudinary.
- **Antarmuka Responsif (UI)**: Antarmuka yang indah dan dinamis, dioptimalkan untuk berbagai ukuran layar menggunakan `flutter_screenutil`.

## 🛠️ Teknologi yang Digunakan
- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Manajemen State**: [Provider](https://pub.dev/packages/provider)
- **Backend & Database**: Firebase (Auth, Firestore)
- **Integrasi AI**: [Google Generative AI (Gemini)](https://pub.dev/packages/google_generative_ai)
- **Penyimpanan Cloud**: [Cloudinary](https://cloudinary.com/)
- **Penyimpanan Lokal**: Shared Preferences

## 🚀 Cara Menjalankan Project

Ikuti instruksi berikut untuk menjalankan project ini di komputer lokal Anda untuk tujuan pengembangan dan pengujian.

### Persyaratan Sistem
- Flutter SDK (v3.12.2 atau lebih baru)
- Android Studio / Xcode untuk emulator
- Project Firebase
- Akun Cloudinary
- API Key Gemini

### Instalasi

1. **Clone repository ini**
   ```bash
   git clone https://github.com/USERNAME_ANDA/sihijau_app.git
   cd sihijau_app
   ```

2. **Install dependensi**
   ```bash
   flutter pub get
   ```

3. **Atur Environment Variables (Variabel Lingkungan)**
   - Salin file `.env.example` untuk membuat file `.env` baru:
     ```bash
     cp .env.example .env
     ```
   - Buka file `.env` dan isi dengan API keys Anda:
     ```env
     GEMINI_API_KEY=api_key_gemini_anda
     CLOUDINARY_CLOUD_NAME=cloud_name_cloudinary_anda
     CLOUDINARY_UPLOAD_PRESET=upload_preset_anda
     ```

4. **Pengaturan Firebase**
   - **Android**: Tambahkan file `google-services.json` milik Anda (lihat `google-services.example.json` untuk struktur) ke folder `android/app/`.
   - **iOS**: Tambahkan file `GoogleService-Info.plist` milik Anda (lihat `GoogleService-Info.example.plist` untuk struktur) ke folder `ios/Runner/`.

5. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

## 📱 Tangkapan Layar (Screenshots)
*(Tambahkan tangkapan layar aplikasi Anda di sini dengan mengunggahnya ke folder `assets/screenshots` dan menautkannya seperti ini: `![Beranda](assets/screenshots/home.png)`)*

## 🛡️ Keamanan (Security)
File konfigurasi sensitif dan API key telah diamankan sesuai standar:
- Konfigurasi Firebase (`google-services.json`, `GoogleService-Info.plist`) telah diabaikan melalui file `.gitignore`.
- API keys (Gemini, Cloudinary) dikelola secara aman menggunakan `flutter_dotenv`.

---
*Dibuat oleh Muhammad Dicky Adicandra*
