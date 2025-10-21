# Widget Yapısı

Bu klasör uygulamanın yeniden kullanılabilir widget'larını içerir.

## Ortak Widget'lar

### **story_card_widget.dart**
- Liste görünümünde hikaye kartı
- Kullanım: Ana Sayfa, Favoriler
- Özellikler: Başlık, açıklama, süre, favori butonu, oynat butonu

### **story_grid_card_widget.dart**
- Grid görünümünde hikaye kartı  
- Kullanım: Keşfet sayfası
- Özellikler: Başlık, açıklama, süre, floating favori butonu

### **category_card_widget.dart**
- Kategori kartı
- Kullanım: Ana Sayfa
- Özellikler: İkon, başlık, renk, tıklanabilir

## Tab Widget'ları

### **home_tab_widget.dart**
Ana sayfa içeriği
- Kategoriler listesi
- Popüler hikayeler
- Banner reklamlar

### **explore_tab_widget.dart**
Keşfet sayfası içeriği
- Arama çubuğu
- Kategori filtreleri
- Yaş filtreleri
- Hikaye grid'i

### **favorites_tab_widget.dart**
Favoriler sayfası içeriği
- Favori hikaye listesi
- Boş durum (empty state)
- Favori sayısı gösterimi

## MVVM Pattern

Tüm widget'lar MVVM yapısına uygun olarak tasarlanmıştır:
- Widget'lar sadece UI render eder
- Business logic ViewModel'de bulunur
- Veri işlemleri Service katmanında yapılır

