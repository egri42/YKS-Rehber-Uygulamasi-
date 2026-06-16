# 📚 YKS Rehber — Akıllı Ders Takip Uygulaması

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.11+-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-brightgreen?style=for-the-badge" />
</p>

<p align="center">
  <b>Hibrit Karar Destek Mekanizmalı, YKS'ye Hazırlık Sürecini Uçtan Uca Yöneten Flutter Uygulaması</b>
</p>

---

## 🎯 Proje Hakkında

**YKS Rehber**, üniversite sınavına (YKS/TYT/AYT) hazırlanan öğrenciler için geliştirilmiş, **Firebase tabanlı**, **gerçek zamanlı** bir ders takip ve planlama uygulamasıdır.

Uygulama, öğrencinin çalışma düzenini **algoritmik olarak analiz eder**, kişiselleştirilmiş öneriler sunar ve Pomodoro tekniği ile verimli çalışma seansları oluşturur. Glassmorphism tasarım dili ile modern ve şık bir kullanıcı deneyimi sağlar.

> **Geliştirici:** Mehmet Emin Eğri — 231213053  
> **Proje Türü:** Hibrit Karar Destek Mekanizmalı Ders Takip Uygulaması

---

## ✨ Özellikler

### 🏠 Ana Sayfa (Dashboard)
- **YKS Geri Sayım Sayacı** — Sınav tarihine kalan gün, saat ve dakikayı canlı olarak gösterir
- **Sıradaki Görev** — Bugünkü planlardan en yakın tamamlanmamış görevi akıllıca seçer
- **Verimlilik Analizi** — Günlük odak süresi, hedef yüzdesi ve günün şampiyonu dersi
- **Günün Taktiği** — Her gün farklı, kanıta dayalı çalışma stratejileri sunar
- **Çalışma Serisi (Streak)** — Aralıksız kaç gündür çalışıldığını takip eder

### 📅 Günlük Plan Sayfası
- **Timeline tabanlı** saat dilimi görünümü (07:00 – 23:00)
- Ders ve konu seçimli plan oluşturma (müfredat veritabanından)
- **Konfeti animasyonu** ile görev tamamlama kutlaması 🎉
- Saat bazlı başlangıç/bitiş scroll picker
- Geçmiş ve gelecek günlere plan ekleme (±7 gün)
- Uzun basma ile plan silme, dokunma ile tamamlama

### ⏱️ Pomodoro Zamanlayıcı
- 1–120 dakika arası özelleştirilebilir odak süresi (scroll wheel picker)
- **Akıllı mola önerisi** — Süreye göre otomatik mola hesaplama
- Çoklu etüt (seans) desteği
- **Karanlık odaklanma modu** — Dikkat dağıtmayan minimal arayüz
- Nabız animasyonu ile aktif zamanlayıcı göstergesi
- Tamamlanan seanslar otomatik olarak plana ve istatistiklere eklenir

### 📊 Performans Analizi
- **Haftalık / Aylık** toggle ile zaman dilimi seçimi
- Gün bazlı bar chart grafiği (tamamlanan dakikalar)
- **Ders Analizi** — En çok ve en az çalışılan dersler
- **5 Katmanlı Akıllı Öneri Sistemi:**
  - 📌 **Günlük** — Bugün yapılmamış görevler
  - ⚖️ **Haftalık** — Ders dengesi analizi
  - 📈 **Aylık** — Geçen aya kıyasla düşen dersler
  - 🎯 **Konu Takip** — Aksatılan konular
  - 🔄 **Tekrar** — Uzun süredir çalışılmayan konular (Unutma eğrisi uyarısı)

### 🧮 YKS Sıralama Tahmini (Hibrit Karar Destek Motoru)
- **2024 ve 2025** resmi ÖSYM verilerine dayalı puan hesaplama
- TYT, AYT Sayısal, EA ve Sözel puan türlerinin ayrı ayrı hesaplanması
- **Doğrusal interpolasyon** ile hassas sıralama tahmini
- Net girişleri 0.25 hassasiyetle slider ile ayarlanabilir
- OBP (Diploma Notu) dahil kapsamlı hesaplama

### 🤖 Özel Mentor Sistemi
- 3 farklı mentor profili (Analitik Stratejist, Psikolog, Derece Koçu)
- Mentor kartları ile profil inceleme
- Sohbet arayüzü ile mesajlaşma
- Otomatik karşılama ve yanıt mesajları

### 🔐 Kimlik Doğrulama
- Firebase Authentication ile güvenli giriş/kayıt
- E-posta ve şifre bazlı kimlik doğrulama
- Glassmorphism tasarımlı auth sayfası
- Detaylı Türkçe hata mesajları

---

## 🛠️ Teknoloji Yığını

| Katman | Teknoloji |
|--------|-----------|
| **Framework** | Flutter 3.11+ (Dart) |
| **State Management** | Singleton Pattern + ChangeNotifier + ListenableBuilder |
| **Backend** | Firebase (Authentication + Cloud Firestore) |
| **Veritabanı** | Cloud Firestore (gerçek zamanlı senkronizasyon) |
| **Kimlik Doğrulama** | Firebase Auth (E-posta/Şifre) |
| **Tasarım Dili** | Material Design 3, Glassmorphism, BackdropFilter |
| **Animasyonlar** | Confetti, Pulse Animation, Micro-interactions |
| **Lokalizasyon** | intl (Türkçe tarih formatlama) |

---

## 📁 Proje Dosya Yapısı

```
YKS-Rehber-Uygulamasi-/
|-- lib/
|   |-- main.dart                          # Uygulama giris noktasi, routing, auth wrapper
|   |-- plan_store.dart                    # Plan veri yonetimi (Firestore + Singleton)
|   |-- firebase_options.dart              # Firebase yapilandirma ayarlari
|   |
|   |-- data/
|   |   +-- curriculum_data.dart           # TYT/AYT mufredat veritabani + ders renkleri
|   |
|   |-- logic/
|   |   +-- study_session_store.dart       # Pomodoro seans takibi (Firestore + Singleton)
|   |
|   |-- services/
|   |   +-- auth_service.dart              # Firebase Auth singleton servisi
|   |
|   +-- screens/
|       |-- home_page.dart                 # Ana sayfa - Dashboard, YKS sayaci, verimlilik
|       |-- PlanPage.dart                  # Gunluk plan - Timeline, ders ekleme/silme
|       |-- pomodoro_page.dart             # Pomodoro zamanlayici - Odak + mola dongusu
|       |-- study_tracking_page.dart       # Performans analizi - Grafikler, oneriler
|       |-- puan_hesapla_page.dart         # YKS puan/siralama tahmini
|       |-- yks_motoru.dart                # Hibrit hesaplama motoru (2024/2025 verileri)
|       |-- auth_page.dart                 # Giris/kayit sayfasi
|       |-- mentor_list_page.dart          # Mentor listesi ve profil kartlari
|       +-- chat_page.dart                 # Mentor sohbet arayuzu
|
|-- assets/
|   +-- icon/
|       +-- app_icon.png                   # Uygulama ikonu
|
|-- android/                               # Android platform ayarlari
|-- ios/                                   # iOS platform ayarlari
|-- web/                                   # Web platform ayarlari
|-- windows/                               # Windows platform ayarlari
|-- linux/                                 # Linux platform ayarlari
|-- macos/                                 # macOS platform ayarlari
|-- test/                                  # Birim testleri
|
|-- pubspec.yaml                           # Proje bagimliliklari ve yapilandirma
|-- pubspec.lock                           # Bagimlilik kilit dosyasi
|-- firebase.json                          # Firebase hosting yapilandirmasi
|-- analysis_options.yaml                  # Dart analiz kurallari
+-- README.md                              # Bu dosya
```

---

## Mimari Yapi

```mermaid
graph TD
    A["UI Layer - Screens"] --> B["State Management"]
    B --> C["Services"]
    B --> D["Data Layer"]
    C --> E["Firebase Backend"]
    D --> E

    A --- A1["HomePage"]
    A --- A2["PlanPage"]
    A --- A3["PomodoroPage"]
    A --- A4["StudyTrackingPage"]
    A --- A5["AuthPage"]

    B --- B1["PlanStore - Singleton + ChangeNotifier"]
    B --- B2["StudySessionStore - Singleton + ChangeNotifier"]

    C --- C1["AuthService - Singleton"]

    D --- D1["curriculum_data.dart"]
    D --- D2["yks_motoru.dart"]

    E --- E1["Cloud Firestore"]
    E --- E2["Firebase Auth"]
```

**Veri Akışı:**
1. Kullanıcı uygulamaya Firebase Auth ile giriş yapar
2. `AuthWrapper` auth durumunu dinler → Store'ları kullanıcı UID'si ile başlatır
3. `PlanStore` ve `StudySessionStore` Firestore'daki ilgili koleksiyonları gerçek zamanlı dinler
4. UI bileşenleri `ChangeNotifier` ile otomatik güncellenir
5. Pomodoro tamamlandığında otomatik olarak hem `StudySessionStore`'a hem `PlanStore`'a kaydedilir

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK 3.11+
- Dart SDK 3.11+
- Firebase projesi (Auth + Firestore aktif)
- Android Studio veya VS Code

### Adımlar

```bash
# 1. Projeyi klonlayin
git clone https://github.com/egri42/YKS-Rehber-Uygulamasi-.git
cd YKS-Rehber-Uygulamasi-

# 2. Bağımlılıkları yükleyin
flutter pub get

# 3. Firebase yapılandırmasını ayarlayın
# (firebase_options.dart dosyanızı kendi Firebase projenizle oluşturun)
flutterfire configure

# 4. Uygulamayı çalıştırın
flutter run
```

### Firebase Firestore Kuralları (Önerilen)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 📦 Bağımlılıklar

| Paket | Sürüm | Açıklama |
|-------|--------|----------|
| `flutter` | SDK | Ana framework |
| `firebase_core` | ^4.7.0 | Firebase temel altyapı |
| `cloud_firestore` | ^6.3.0 | Gerçek zamanlı veritabanı |
| `firebase_auth` | ^6.4.0 | Kimlik doğrulama |
| `intl` | ^0.20.2 | Türkçe tarih/saat formatlama |
| `confetti` | ^0.8.0 | Konfeti animasyonu |
| `cupertino_icons` | ^1.0.8 | iOS tarzı ikonlar |

### Geliştirici Bağımlılıkları

| Paket | Sürüm | Açıklama |
|-------|--------|----------|
| `flutter_test` | SDK | Birim test framework |
| `flutter_lints` | ^6.0.0 | Kod kalitesi kuralları |
| `flutter_launcher_icons` | ^0.13.1 | Uygulama ikonu oluşturucu |

---

## 🎨 Ekran Görüntüleri

### Kimlik Dogrulama ve Ana Sayfa
| Giris / Kayit | Ana Sayfa | Plan Ekleme |
|:-:|:-:|:-:|
| ![Giris Sayfasi](screenshots/auth.jpg) | ![Ana Sayfa](screenshots/home.jpg) | ![Plan Ekleme](screenshots/plan.jpg) |

### Pomodoro ve Basari
| Pomodoro Zamanlayici | Gorev Tamamlama | Performans Analizi |
|:-:|:-:|:-:|
| ![Pomodoro](screenshots/pomodoro.jpg) | ![Confetti](screenshots/confetti.jpg) | ![Performans](screenshots/tracking.jpg) |

### Akilli Oneri Sistemi
| Oneriler 1 | Oneriler 2 | Oneriler 3 |
|:-:|:-:|:-:|
| ![Oneriler 1](screenshots/suggestions1.jpg) | ![Oneriler 2](screenshots/suggestions2.jpg) | ![Oneriler 3](screenshots/suggestions3.jpg) |

### Mentor ve Puan Hesaplama
| Mentor ve Sohbet | YKS Puan Hesaplama |
|:-:|:-:|
| ![Mentor](screenshots/mentor.jpg) | ![Puan Hesaplama](screenshots/puan.jpg) |

---

## 🔑 Temel Tasarım Kararları

- **Singleton Pattern:** `PlanStore`, `StudySessionStore` ve `AuthService` tek örnek olarak çalışır. Bu sayede tüm ekranlar aynı veri kaynağını paylaşır.
- **Firestore Realtime Sync:** Veriler `snapshots()` stream'i ile gerçek zamanlı dinlenir. Herhangi bir cihazdan yapılan değişiklik anında yansır.
- **Glassmorphism UI:** `BackdropFilter` ve `ImageFilter.blur` ile cam efektli modern arayüz.
- **Hibrit Karar Destek:** YKS puan hesaplama motoru, ÖSYM'nin resmi veri tabloları ile doğrusal interpolasyon kullanarak hassas sıralama tahmini yapar.
- **Akıllı Öneri Motoru:** 5 katmanlı analiz sistemi (Günlük → Haftalık → Aylık → Konu Bazlı → Tekrar) ile öğrenciye kişiselleştirilmiş yol haritası çizer.

---

## 🤝 Katkıda Bulunma

1. Bu repoyu **fork** edin
2. Yeni bir **branch** oluşturun (`git checkout -b feature/ozellik-adi`)
3. Değişikliklerinizi **commit** edin (`git commit -m 'Yeni özellik eklendi'`)
4. Branch'inizi **push** edin (`git push origin feature/ozellik-adi`)
5. Bir **Pull Request** açın

---

## 📄 Lisans

Bu proje eğitim amaçlı geliştirilmiştir.

---

<p align="center">
  ⭐ Projeyi beğendiyseniz yıldız vermeyi unutmayın!
</p>
