# FMEA (Failure Mode and Effects Analysis) Sistemi

## 📋 Genel Bakış

Bu proje, ASP.NET Web Forms ve Bootstrap 5 kullanılarak geliştirilmiş tam özellikli bir FMEA yönetim sistemidir. Üretim süreçlerindeki potansiyel hataları analiz etmek, risk öncelik numaralarını (RPN) hesaplamak ve azaltıcı aksiyonları takip etmek için kullanılır.

## ✨ Özellikler

### ✅ Temel Özellikler
- **FMEA Kayıt Yönetimi**: Yeni kayıt ekleme, düzenleme, silme
- **RPN Otomatik Hesaplama**: Şiddet × Oluşma × Tespit
- **Risk Seviyesi Renklendirme**: 
  - 🔴 Yüksek Risk (RPN ≥ 200)
  - 🟡 Orta Risk (100 ≤ RPN < 200)
  - 🟢 Düşük Risk (RPN < 100)
- **Arama ve Filtreleme**: Proses adı, hata modu, sorumlu kişiye göre
- **Sayfalama**: Büyük veri setleri için

### 🆕 Gelişmiş Özellikler (Üretim Ortamı İçin)

#### 1. Veritabanı Entegrasyonu
- ✅ MS-SQL Server veritabanı
- ✅ ADO.NET ile veri erişimi
- ✅ Stored Procedure'lar
- ✅ Transaction yönetimi
- ✅ View'lar ile özet raporlar

#### 2. Kullanıcı Yönetimi
- ✅ Authentication (Oturum yönetimi)
- ✅ Authorization (Yetkilendirme)
- ✅ Rol bazlı erişim kontrolü (Admin, Manager, User, Viewer)
- ✅ Şifre hash'leme (SHA256)
- ✅ Login/Logout sayfaları
- ✅ Erişim reddedildi sayfası

#### 3. Excel Export
- ✅ EPPlus ile gerçek Excel export (.xlsx)
- ✅ CSV export seçeneği
- ✅ RPN değerlerine göre otomatik renklendirme
- ✅ Formatlanmış başlık satırları

#### 4. Raporlama
- ✅ Pareto analizi (80/20 kuralı)
- ✅ Trend grafikleri
- ✅ Risk dağılım pastası
- ✅ PDF rapor oluşturma (HTML tabanlı)
- ✅ Dashboard istatistikleri

#### 5. Düzenleme İşlevi
- ✅ Mevcut kayıtları güncelleme
- ✅ Versiyon geçmişi takibi
- ✅ Değişiklik logları (ActionHistory tablosu)
- ✅ Kayıt kilitleme mekanizması (hazır altyapı)

#### 6. Bildirimler
- ✅ E-posta bildirim sistemi (SMTP)
- ✅ Hedef tarihi yaklaşan aksiyonlar için hatırlatma
- ✅ Yüksek riskli kayıtlar için yönetici uyarısı
- ✅ Haftalık özet raporu

## 🏗️ Proje Yapısı

```
FMEASystem/
├── App_Data/                  # Veritabanı dosyaları
├── Database/
│   └── FMEADatabase.sql      # Veritabanı kurulum script'i
├── Handlers/                  # HTTP Handler'lar
├── Helpers/
│   ├── AuthenticationHelper.cs    # Kimlik doğrulama
│   ├── EmailNotificationHelper.cs # E-posta bildirimleri
│   ├── ExcelExportHelper.cs       # Excel/CSV export
│   └── ReportingHelper.cs         # Raporlama ve grafikler
├── Models/
│   ├── FMEAItem.cs           # FMEA kayıt modeli
│   ├── FMEAEditHelper.cs     # Düzenleme yardımcı
│   └── User.cs               # Kullanıcı modeli
├── Properties/
│   └── AssemblyInfo.cs
├── Reports/                   # Rapor dosyaları
├── AccessDenied.aspx         # Erişim reddedildi
├── AccessDenied.aspx.cs
├── Default.aspx              # Ana sayfa
├── Default.aspx.cs
├── Login.aspx                # Giriş sayfası
├── Login.aspx.cs
├── Logout.aspx               # Çıkış işlemi
├── Logout.aspx.cs
├── Reports.aspx              # Raporlar ve analizler
├── Reports.aspx.cs
├── Web.config                # Konfigürasyon
└── README.md                 # Bu dosya
```

## 🚀 Kurulum

### 1. Veritabanı Kurulumu
```sql
-- SQL Server Management Studio'da çalıştırın
Database/FMEADatabase.sql
```

### 2. Connection String Ayarı
Web.config dosyasındaki connection string'i kendi SQL Server bilgilerinizle güncelleyin:
```xml
<connectionStrings>
  <add name="FMEAConnection" 
       connectionString="Data Source=SERVER_NAME;Initial Catalog=FMEADatabase;Integrated Security=True;" />
</connectionStrings>
```

### 3. NuGet Paketleri (İsteğe Bağlı)
```powershell
# EPPlus - Excel export için
Install-Package EPPlus

# iTextSharp - PDF export için (opsiyonel)
Install-Package iTextSharp
```

### 4. SMTP Ayarları (E-posta Bildirimleri için)
Web.config'de SMTP ayarlarını yapın:
```xml
<appSettings>
  <add key="SMTPServer" value="smtp.gmail.com" />
  <add key="SMTPPort" value="587" />
  <add key="SenderEmail" value="fmea@firma.com" />
  <add key="SenderPassword" value="your_password" />
  <add key="SMTPEnableSSL" value="true" />
</appSettings>
```

### 5. Projeyi Çalıştırma
1. Visual Studio'da projeyi açın
2. F5 tuşuna basın veya Debug > Start Debugging
3. Tarayıcıda otomatik olarak açılacaktır

## 👤 Demo Kullanıcılar

| Kullanıcı Adı | Şifre | Rol |
|--------------|-------|-----|
| admin | admin123 | Admin |
| ayse.demir | demo123 | Manager |
| ahmet.yilmaz | demo123 | User |

## 📊 Veritabanı Tabloları

### Ana Tablolar
- **FMEAItems**: FMEA kayıtları
- **Users**: Kullanıcı bilgileri
- **ActionHistory**: Değişiklik geçmişi

### Görünümler (Views)
- **vw_FMEARiskSummary**: Risk seviyesine göre özet
- **vw_FMEAStatusSummary**: Duruma göre özet
- **vw_ResponsiblePersonSummary**: Sorumlu kişi dağılımı
- **vw_OverdueActions**: Geciken aksiyonlar

### Stored Procedure'lar
- **sp_AddFMEAItem**: Yeni kayıt ekle
- **sp_UpdateFMEAItem**: Kayıt güncelle
- **sp_DeleteFMEAItem**: Kayıt sil
- **sp_SearchFMEAItems**: Kayıt ara
- **sp_GetDashboardStatistics**: Dashboard istatistikleri

## 🔐 Güvenlik Özellikleri

1. **Şifre Hash'leme**: SHA256 algoritması
2. **Session Yönetimi**: 30 dakika timeout
3. **Rol Bazlı Erişim**: Admin, Manager, User, Viewer
4. **SQL Injection Koruması**: Parameterized queries
5. **XSS Koruması**: Input validation

## 📈 Kullanım Senaryoları

### Yeni FMEA Kaydı Ekleme
1. Ana sayfada form alanlarını doldurun
2. Şiddet, Oluşma, Tespit değerlerini seçin (1-10)
3. RPN otomatik hesaplanır
4. "Kaydet" butonuna tıklayın

### Raporları Görüntüleme
1. Navbar'dan "Raporlar" menüsüne tıklayın
2. Pareto analizi, risk dağılımı grafiklerini görüntüleyin
3. En kritik hata modlarını inceleyin

### Excel/CSV Export
1. Raporlar sayfasında "Dışa Aktar" menüsünü açın
2. İstediğiniz formatı seçin (Excel, CSV, PDF)
3. Dosya otomatik indirilecektir

### E-posta Bildirimleri
```csharp
// Manuel tetikleme örneği
EmailNotificationHelper.SendDueDateReminders();
EmailNotificationHelper.SendHighRiskAlert(fmeaItemId);
EmailNotificationHelper.SendWeeklySummaryReport();
```

## 🔧 Yapılandırma Seçenekleri

### Session Timeout Süresi
```xml
<sessionState mode="InProc" timeout="30" />
```

### Forms Authentication
```xml
<authentication mode="Forms">
  <forms loginUrl="~/Login.aspx" timeout="30" slidingExpiration="true" />
</authentication>
```

## 📝 Gelecek Geliştirmeler

- [ ] Entity Framework entegrasyonu
- [ ] SignalR ile real-time bildirimler
- [ ] Angular/React frontend
- [ ] REST API endpoints
- [ ] Docker containerization
- [ ] Azure DevOps CI/CD pipeline
- [ ] Multi-language support
- [ ] Advanced filtering options
- [ ] Bulk import/export
- [ ] Mobile responsive improvements

## 📄 Lisans

Bu proje eğitim ve demonstrasyon amaçlıdır.

## 👥 Katkıda Bulunma

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/YeniOzellik`)
3. Değişikliklerinizi commit edin (`git commit -am 'Yeni özellik eklendi'`)
4. Branch'i push edin (`git push origin feature/YeniOzellik`)
5. Pull Request oluşturun

## 📞 İletişim

Sorularınız için: fmea-support@firma.com

---

**Not**: Bu sistem üretim ortamında kullanılmadan önce güvenlik testlerinden geçirilmeli ve şirket politikalarına göre özelleştirilmelidir.
