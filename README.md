# 📚 Hikayeler ve Masallar

Çocuklar için tasarlanmış, eğitici ve eğlenceli hikaye uygulaması. Flutter ile geliştirilmiş modern bir mobil uygulama.

## ✨ Özellikler

- **📖 Zengin Hikaye Koleksiyonu**: Çeşitli kategorilerde hikayeler ve masallar
- **🎯 Yaş Gruplarına Uygun**: 3-5, 6-8, 9-12 yaş grupları için optimize edilmiş içerik
- **❤️ Favori Sistemi**: Beğenilen hikayeleri favorilere ekleme
- **🔍 Akıllı Arama**: Başlık ve içeriğe göre hikaye arama
- **📱 Modern UI/UX**: Material 3 tasarım prensipleri ile geliştirilmiş arayüz
- **🔐 Google Sign-In**: Güvenli giriş sistemi
- **☁️ Firebase Entegrasyonu**: Bulut tabanlı veri yönetimi
- **📊 İstatistikler**: Okuma ilerlemesi ve popülerlik takibi

## 🏗️ Teknik Özellikler

- **Framework**: Flutter 3.8.1+
- **State Management**: Provider
- **Backend**: Firebase (Firestore, Auth)
- **Authentication**: Google Sign-In
- **Ads**: Google Mobile Ads (AdMob)
- **Architecture**: MVVM Pattern
- **Language**: Dart

## 📱 Ekran Görüntüleri

*Ekran görüntüleri buraya eklenebilir*

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.8.1+
- Android Studio / VS Code
- Firebase projesi
- Google Cloud Console hesabı

### Adımlar

1. **Projeyi klonlayın**
```bash
git clone https://github.com/yourusername/stories_and_tales.git
cd stories_and_tales
```

2. **Bağımlılıkları yükleyin**
```bash
flutter pub get
```

3. **Firebase yapılandırması**
   - `google-services.json` dosyasını `android/app/` klasörüne ekleyin
   - Firebase Console'da SHA-1 sertifika hash'lerini ekleyin

4. **Uygulamayı çalıştırın**
```bash
flutter run
```

## 📂 Proje Yapısı

```
lib/
├── main.dart                 # Uygulama giriş noktası
├── models/                   # Veri modelleri
│   ├── story_model.dart
│   ├── category_model.dart
│   ├── reading_progress_model.dart
│   └── settings_model.dart
├── services/                 # İş mantığı servisleri
│   ├── auth_service.dart
│   ├── story_service.dart
│   ├── category_service.dart
│   ├── favorite_service.dart
│   └── reading_progress_service.dart
├── viewmodels/               # ViewModel sınıfları
│   ├── auth_viewmodel.dart
│   ├── home_viewmodel.dart
│   ├── profile_viewmodel.dart
│   └── story_reading_viewmodel.dart
├── views/                    # UI ekranları
│   ├── home_view.dart
│   ├── login_view.dart
│   ├── profile_view.dart
│   ├── story_reading_view.dart
│   └── widgets/              # Yeniden kullanılabilir widget'lar
└── assets/                   # Statik dosyalar
    └── icons/
```

## 🎨 Tasarım Sistemi

- **Ana Renk**: `#6C63FF` (Mor gradient)
- **Arka Plan**: `#FAFBFF` (Açık mavi-beyaz)
- **Font**: Google Fonts Poppins
- **Border Radius**: 12-16px (kartlar), 8px (butonlar)

## 🔧 Geliştirme

### Kod Standartları
- Snake_case dosya adlandırma
- MVVM mimari deseni
- Provider state management
- Material 3 tasarım prensipleri

### Build Komutları
```bash
# Debug build
flutter run --debug

# Release build
flutter build apk --release

# App bundle (Play Store için)
flutter build appbundle --release
```

## 📦 Bağımlılıklar

### Ana Paketler
- `google_sign_in: ^7.1.1` - Google giriş
- `firebase_auth: ^6.0.1` - Firebase kimlik doğrulama
- `cloud_firestore: ^6.0.2` - Firebase veritabanı
- `google_mobile_ads: ^6.0.0` - Google reklamları
- `provider: ^6.1.2` - State management
- `google_fonts: ^6.3.0` - Font yönetimi

## 🔐 Güvenlik

- Firebase Authentication ile güvenli giriş
- SHA-1 sertifika doğrulama
- Güvenli veri şifreleme
- GDPR uyumluluğu

## 📊 Firebase Koleksiyonları

- `stories` - Hikaye verileri
- `categories` - Kategori bilgileri
- `users` - Kullanıcı profilleri
- `reading_progress` - Okuma ilerlemesi
- `favorites` - Favori hikayeler

## 🚀 Deployment

### Play Store için
1. Release build alın: `flutter build appbundle --release`
2. Google Play Console'da uygulamayı yükleyin
3. Store listing bilgilerini tamamlayın

### Test
```bash
flutter test
```

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için `LICENSE` dosyasına bakın.

## 📞 İletişim

- **Geliştirici**: Rafet Hokka
- **Email**: [email adresiniz]
- **Proje Linki**: [GitHub repository linki]

## 🙏 Teşekkürler

- Flutter ekibine harika framework için
- Firebase ekibine backend çözümleri için
- Google Fonts ekibine font desteği için

---

**Not**: Bu uygulama çocuklar için tasarlandığından güvenlik ve içerik filtreleme konularında özel özen gösterilmiştir.