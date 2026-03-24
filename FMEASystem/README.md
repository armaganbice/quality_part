# FMEA Sistemi - ASP.NET Web Forms + Bootstrap 5

## Proje Açıklaması

Bu proje, **FMEA (Failure Mode and Effects Analysis - Hata Türleri ve Etkileri Analizi)** yönetimi için geliştirilmiş bir ASP.NET Web Forms uygulamasıdır. Modern ve responsive bir kullanıcı arayüzü için **Bootstrap 5** kullanılmıştır.

## Özellikler

### Temel İşlevler
- ✅ Yeni FMEA kaydı ekleme
- ✅ Kayıtları listeleme (GridView ile)
- ✅ Kayıt silme
- ✅ Arama fonksiyonu
- ✅ RPN (Risk Priority Number) otomatik hesaplama
- ✅ Risk seviyesine göre renkli gösterim
- ✅ İstatistik kartları (Toplam, Yüksek/Orta/Düşük Risk)

### FMEA Alanları
- **Proses Adımı**: İşlem veya prosesin adı
- **Hata Modu**: Potansiyel hata türü
- **Hata Etkisi**: Hatanın sonuçları
- **Hata Nedeni**: Hatanın kök nedeni
- **Şiddet (S)**: 1-10 arası hata şiddeti
- **Oluşma (O)**: 1-10 arası oluşma olasılığı
- **Tespit (D)**: 1-10 arası tespit edilebilirlik
- **RPN**: Risk Öncelik Numarası (S × O × D)
- **Mevcut Kontroller**: Halihazırda bulunan kontrol mekanizmaları
- **Önerilen Aksiyonlar**: İyileştirme önerileri
- **Sorumlu Kişi**: Aksiyondan sorumlu personel
- **Hedef Tarih**: Aksiyonun tamamlanması gereken tarih
- **Durum**: Açık/Kapalı/Devam Ediyor

### RPN Renk Kodlaması
- 🔴 **Yüksek Risk (RPN ≥ 200)**: Kırmızı - Acil aksiyon gerekli
- 🟡 **Orta Risk (100 ≤ RPN < 200)**: Sarı - Aksiyon planlanmalı
- 🟢 **Düşük Risk (RPN < 100)**: Yeşil - Kabul edilebilir risk

## Teknolojiler

- **Framework**: ASP.NET Web Forms (.NET Framework 4.8)
- **Dil**: C#
- **UI Framework**: Bootstrap 5.3.2
- **Icons**: Bootstrap Icons
- **Veri Saklama**: Demo amaçlı bellek (List<T>) - Gerçek uygulamada SQL Server kullanılabilir

## Kurulum

### Gereksinimler
- Visual Studio 2019 veya üzeri
- .NET Framework 4.8
- IIS Express veya IIS

### Çalıştırma Adımları

1. Projeyi Visual Studio'da açın
2. `FMEASystem.sln` dosyasına çift tıklayın
3. `Ctrl+F5` ile çalıştırın veya `F5` ile debug modunda başlatın
4. Tarayıcınızda otomatik olarak açılacaktır

### Manuel Kurulum (IIS)

1. Projeyi build edin (`Build > Build Solution`)
2. IIS'de yeni bir web sitesi veya virtual directory oluşturun
3. Build output'u hedef dizine kopyalayın
4. Uygulamayı browse edin

## Dosya Yapısı

```
FMEASystem/
├── Default.aspx              # Ana sayfa (UI)
├── Default.aspx.cs           # Code-behind (C# logic)
├── Web.config                # Konfigürasyon dosyası
├── FMEASystem.csproj         # Proje dosyası
├── Models/
│   └── FMEAItem.cs          # FMEA veri modeli
└── Properties/
    └── AssemblyInfo.cs       # Assembly bilgileri
```

## Kullanım

### Yeni Kayıt Ekleme
1. Form alanlarını doldurun
2. Şiddet, Oluşma ve Tespit değerlerini seçin (1-10)
3. "Kaydet" butonuna tıklayın
4. RPN otomatik olarak hesaplanır ve tabloya eklenir

### Kayıt Silme
- Tablodaki her satırın sonundaki çöp kutusu ikonuna tıklayın
- Onay mesajını kabul edin

### Arama Yapma
- Arama kutusuna proses adı, hata modu veya sorumlu kişi bilgisini yazın
- Otomatik olarak filtreleme yapılır

### İstatistikler
- Dashboard'daki kartlar anlık istatistikleri gösterir
- Toplam kayıt sayısı
- Risk seviyelerine göre dağılım

## Geliştirme Önerileri

Gerçek bir üretim ortamı için eklenebilecek özellikler:

1. **Veritabanı Entegrasyonu**
   - SQL Server veya başka bir veritabanı kullanımı
   - Entity Framework veya ADO.NET ile veri erişimi

2. **Kullanıcı Yönetimi**
   - Authentication ve Authorization
   - Rol bazlı erişim kontrolü

3. **Excel Export**
   - EPPlus veya ClosedXML ile gerçek Excel export
   - CSV export seçeneği

4. **Raporlama**
   - Pareto analizi
   - Trend grafikleri
   - PDF rapor oluşturma

5. **Düzenleme İşlevi**
   - Mevcut kayıtları güncelleme
   - Versiyon geçmişi

6. **Bildirimler**
   - Hedef tarihi yaklaşan aksiyonlar için e-posta bildirimi
   - Dashboard bildirimleri

## Lisans

Bu proje eğitim ve demo amaçlıdır. Ticari kullanım için uygun şekilde uyarlanmalıdır.

## Katkıda Bulunma

Geliştirmeler ve öneriler için pull request gönderebilirsiniz.

## İletişim

Sorularınız için proje dokümantasyonunu inceleyebilirsiniz.

---

**FMEA** - Failure Mode and Effects Analysis  
**RPN** - Risk Priority Number (Risk Öncelik Numarası)
