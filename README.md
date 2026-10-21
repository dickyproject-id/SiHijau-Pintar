<div align="center">

# 🌿 SiHijau Pintar

### 🇮🇩 Aplikasi Manajemen & Identifikasi Tanaman Berbasis AI
### 🇬🇧 AI-Powered Plant Management & Identification App

<br/>

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Gemini AI](https://img.shields.io/badge/Gemini%20AI-Powered-4285F4?style=for-the-badge&logo=google&logoColor=white)
![Cloudinary](https://img.shields.io/badge/Cloudinary-Cloud%20Storage-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)

</div>

---

## 🇮🇩 Deskripsi Proyek

**SiHijau Pintar** adalah aplikasi mobile Flutter yang membantu pengguna **mengidentifikasi tanaman** secara otomatis dari foto menggunakan kecerdasan buatan (Gemini AI), sekaligus **mengelola koleksi tanaman pribadi** mereka secara efisien.

Aplikasi ini menggabungkan **Google Gemini AI** untuk identifikasi dan tanya jawab seputar tanaman, **Firebase** sebagai backend untuk autentikasi & database, serta **Cloudinary** untuk penyimpanan gambar di cloud.

---

## 🇬🇧 Project Description

**SiHijau Pintar** is a Flutter mobile app that helps users **identify plants** automatically from photos using artificial intelligence (Gemini AI), while efficiently **managing their personal plant collection**.

The app combines **Google Gemini AI** for plant identification and Q&A, **Firebase** as the backend for authentication & database, and **Cloudinary** for cloud image storage.

---

## ✨ Fitur Utama / Core Features

---

### 🇮🇩 Bahasa Indonesia

**A. Identifikasi Tanaman Berbasis AI**

- 🤖 **Identifikasi dari Foto:** Ambil foto atau unggah gambar tanaman untuk mendapatkan identifikasi lengkap yang ditenagai oleh Gemini AI.
- 🌱 **Info Tanaman Lengkap:** Dapatkan nama ilmiah, deskripsi, cara perawatan, kebutuhan air & cahaya secara otomatis.
- 🔬 **Deteksi Penyakit Tanaman:** Analisis kondisi kesehatan tanaman beserta rekomendasi penanganannya.
- 📷 **Multi-Sumber Gambar:** Dukung pengambilan foto dari kamera langsung maupun galeri perangkat.

**B. Koleksi Tanaman Pribadi (My Plants)**

- 🌿 **Tambah & Kelola Tanaman:** Simpan tanaman favorit Anda ke dalam koleksi pribadi lengkap dengan foto.
- 📋 **Detail Tanaman:** Catat nama, jenis, tanggal tanam, dan catatan perawatan untuk setiap tanaman.
- 🖼️ **Upload Foto Tanaman:** Unggah foto tanaman langsung ke Cloudinary untuk penyimpanan cloud.
- 🗑️ **Kelola Koleksi:** Edit atau hapus data tanaman kapan saja.

**C. Tanya Jawab Tanaman (AI Chat)**

- 💬 **Tanya Apapun Soal Tanaman:** Ajukan pertanyaan seputar tanaman dan dapatkan jawaban cerdas dari Gemini AI.
- 📜 **Riwayat Tanya Jawab:** Simpan dan lihat kembali pertanyaan-jawaban sebelumnya.
- 🧠 **Konteks Percakapan:** AI memahami konteks pertanyaan untuk jawaban yang lebih relevan.

**D. Tips & Panduan Tanaman**

- 📚 **Tips Perawatan Tanaman:** Akses panduan perawatan tanaman berdasarkan jenis dan kategori.
- 🌱 **Panduan Kompos:** Informasi lengkap pembuatan dan penggunaan kompos untuk tanaman.
- 🔄 **Konten Ter-update:** Data tips dan panduan dikelola melalui Firestore untuk selalu up-to-date.

**E. Riwayat Identifikasi**

- ☁️ **Tersimpan di Cloud:** Riwayat identifikasi tanaman otomatis tersimpan di Firestore.
- 📅 **Detail Riwayat:** Setiap entri menyimpan tanggal, foto, dan hasil identifikasi lengkap.
- 🔍 **Lihat Detail:** Buka kembali hasil identifikasi sebelumnya kapan saja.

**F. Autentikasi & Profil Pengguna**

- 📧 **Login Email/Password:** Daftar dan masuk menggunakan email dan kata sandi.
- 🔑 **Lupa Password:** Pemulihan kata sandi melalui email dengan tautan reset.
- 👤 **Profil Pengguna:** Kelola data profil dan foto profil akun Anda.
- 🔒 **Keamanan Akun:** Reset password dengan alur yang aman dan terverifikasi.

**G. Admin Panel**

- 🔒 **Akses Terproteksi:** Panel admin hanya bisa diakses oleh pengguna yang berwenang.
- ➕ **Tambah Konten Tips:** Admin dapat menambahkan tips perawatan tanaman baru.
- 🌿 **Kelola Data Penyakit:** Admin mengelola database penyakit tanaman dan solusinya.
- ♻️ **Kelola Panduan Kompos:** Tambah dan kelola panduan kompos dari panel admin.
- ✏️ **Edit & Hapus Konten:** Kelola semua konten yang sudah ada dengan fitur edit dan hapus.

**H. Tampilan & Pengalaman Pengguna (UI/UX)**

- 🎬 **Splash Screen Animasi:** Layar pembuka dengan animasi yang menarik.
- 📱 **Responsif:** Antarmuka yang indah dan dinamis, dioptimalkan untuk berbagai ukuran layar menggunakan `flutter_screenutil`.
- 🎨 **Desain Modern:** UI yang bersih dan intuitif dengan Google Fonts.

---

### 🇬🇧 English

**A. AI-Powered Plant Identification**

- 🤖 **Photo Identification:** Take a photo or upload an image to get complete plant identification powered by Gemini AI.
- 🌱 **Complete Plant Info:** Automatically receive scientific name, description, care instructions, and water & light requirements.
- 🔬 **Plant Disease Detection:** Analyze the health condition of plants with treatment recommendations.
- 📷 **Multi-Source Images:** Supports capturing photos from the camera or selecting from the device gallery.

**B. My Plants Collection**

- 🌿 **Add & Manage Plants:** Save your favorite plants to a personal collection with photos.
- 📋 **Plant Details:** Record name, type, planting date, and care notes for each plant.
- 🖼️ **Upload Plant Photos:** Upload plant photos directly to Cloudinary for cloud storage.
- 🗑️ **Manage Collection:** Edit or delete plant data at any time.

**C. Plant Q&A (AI Chat)**

- 💬 **Ask Anything About Plants:** Ask questions about plants and get smart answers from Gemini AI.
- 📜 **Q&A History:** Save and review your previous questions and answers.
- 🧠 **Conversation Context:** AI understands the context for more relevant answers.

**D. Plant Tips & Guides**

- 📚 **Plant Care Tips:** Access plant care guides based on type and category.
- 🌱 **Compost Guides:** Complete information on making and using compost for plants.
- 🔄 **Updated Content:** Tips and guide data managed via Firestore to stay up-to-date.

**E. Identification History**

- ☁️ **Cloud Saved:** Plant identification history is automatically saved to Firestore.
- 📅 **History Details:** Each entry stores the date, photo, and complete identification results.
- 🔍 **View Details:** Reopen previous identification results at any time.

**F. Authentication & User Profile**

- 📧 **Email/Password Login:** Register and sign in using email and password.
- 🔑 **Forgot Password:** Password recovery via email with a reset link.
- 👤 **User Profile:** Manage your account profile data and profile picture.
- 🔒 **Account Security:** Secure and verified password reset flow.

**G. Admin Panel**

- 🔒 **Protected Access:** The admin panel is only accessible to authorized users.
- ➕ **Add Tips Content:** Admin can add new plant care tips.
- 🌿 **Manage Disease Data:** Admin manages the plant disease database and solutions.
- ♻️ **Manage Compost Guides:** Add and manage compost guides from the admin panel.
- ✏️ **Edit & Delete Content:** Manage all existing content with edit and delete features.

**H. UI/UX**

- 🎬 **Animated Splash Screen:** An attractive animated loading screen on app launch.
- 📱 **Responsive:** Beautiful, dynamic interface optimized for various screen sizes using `flutter_screenutil`.
- 🎨 **Modern Design:** Clean and intuitive UI with Google Fonts.

---

## 🧰 Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.x / Dart 3.x |
| **State Management** | Provider |
| **Backend & Database** | Firebase Auth, Cloud Firestore, Firebase Remote Config |
| **AI Integration** | Google Generative AI (Gemini) |
| **Cloud Storage** | Cloudinary, Firebase Storage |
| **Local Storage** | Shared Preferences |
| **Image Handling** | Image Picker, Image Cropper |
| **Deep Linking** | App Links |
| **Utilities** | intl, flutter_dotenv, flutter_screenutil, Google Fonts |

---

## ⚙️ Setup Firebase (Wajib / Required)

File konfigurasi Firebase **tidak disertakan** di repo ini karena mengandung API Key rahasia.  
Firebase config files are **not included** in this repo as they contain secret API keys.

**1. Buat project Firebase / Create a Firebase Project**
- Buka / Open: [https://console.firebase.google.com/](https://console.firebase.google.com/)
- Aktifkan / Enable: **Authentication**, **Cloud Firestore**, **Firebase Storage**

**2. Setup `lib/firebase_options.dart`**
```bash
# Gunakan FlutterFire CLI / Use FlutterFire CLI
flutterfire configure
```

**3. Setup `android/app/google-services.json`**
- Download dari / Download from: Firebase Console → Project Settings → Android

**4. Setup `ios/Runner/GoogleService-Info.plist`** *(untuk iOS / for iOS)*
- Download dari / Download from: Firebase Console → Project Settings → iOS Apps

---

## 🚀 Menjalankan Aplikasi / Running the App

```bash
# 1. Clone repository
git clone https://github.com/dickyproject-id/SiHijau-Pintar.git
cd SiHijau-Pintar

# 2. Install dependencies
flutter pub get

# 3. Setup environment variables
cp .env.example .env
# Buka .env dan isi API keys / Open .env and fill in your API keys:
# GEMINI_API_KEY=your_gemini_api_key
# CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
# CLOUDINARY_UPLOAD_PRESET=your_upload_preset

# 4. Setup Firebase (lihat bagian di atas / see section above)

# 5. Jalankan / Run
flutter run
```

---

## 🛡️ Keamanan / Security

File konfigurasi sensitif dan API key telah diamankan:
- Konfigurasi Firebase (`google-services.json`, `GoogleService-Info.plist`) diabaikan via `.gitignore`.
- API keys (Gemini, Cloudinary) dikelola secara aman menggunakan `flutter_dotenv`.

Sensitive configuration files and API keys have been secured:
- Firebase configs are excluded via `.gitignore`.
- API keys (Gemini, Cloudinary) are securely managed using `flutter_dotenv`.

---

## 📁 Struktur Proyek / Project Structure

```
lib/
├── core/
│   ├── models/
│   │   ├── compost_guide_model.dart    # Model panduan kompos
│   │   ├── history_model.dart          # Model riwayat identifikasi
│   │   ├── my_plant_model.dart         # Model koleksi tanaman pribadi
│   │   ├── plant_disease_model.dart    # Model penyakit tanaman
│   │   └── plant_tips_model.dart       # Model tips perawatan tanaman
│   ├── services/
│   │   ├── api_key_manager.dart        # Manajemen API key
│   │   ├── auth_service.dart           # Firebase Authentication
│   │   ├── cloudinary_service.dart     # Upload gambar ke Cloudinary
│   │   ├── firestore_service.dart      # Operasi Cloud Firestore
│   │   ├── gemini_service.dart         # Integrasi Gemini AI
│   │   └── quota_service.dart          # Manajemen kuota penggunaan
│   └── theme/                          # Design system & tema
├── ui/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── reset_password_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── foto_tanaman_screen.dart
│   │   │   └── hasil_foto_screen.dart
│   │   ├── profile/
│   │   │   ├── profil_screen.dart
│   │   │   ├── my_plants_screen.dart
│   │   │   ├── add_plant_screen.dart
│   │   │   ├── history_screen.dart
│   │   │   └── detail_history_screen.dart
│   │   ├── tanya_jawab/
│   │   │   ├── tanya_tanaman_screen.dart
│   │   │   ├── tanya_jawab_list_screen.dart
│   │   │   └── jawaban_screen.dart
│   │   ├── tips/
│   │   │   ├── tips_tanaman_screen.dart
│   │   │   └── kompos_screen.dart
│   │   └── admin/
│   │       ├── admin_dashboard_screen.dart
│   │       ├── home_admin_screen.dart
│   │       ├── input_tips_screen.dart
│   │       ├── input_penyakit_screen.dart
│   │       ├── input_kompos_screen.dart
│   │       ├── list_tips_admin_screen.dart
│   │       ├── list_penyakit_admin_screen.dart
│   │       └── list_kompos_admin_screen.dart
│   └── widgets/
│       ├── bottom_nav_bar.dart
│       ├── custom_button.dart
│       └── custom_textfield.dart
├── firebase_options.dart               # Konfigurasi Firebase (tidak di-commit)
└── main.dart
```

---

## 📱 Screenshots

*(Segera hadir / Coming soon)*

---

<div align="center">

**© 2025 SiHijau Pintar — Muhammad Dicky Adicandra**

</div>
