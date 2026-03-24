# FMEA Sistemi - MS-SQL Veritabanı Kurulum Rehberi

## Genel Bakış

Bu doküman, FMEA (Failure Mode and Effects Analysis) sistemi için MS-SQL veritabanının nasıl oluşturulacağını ve örnek verilerin nasıl yükleneceğini açıklar.

## Gereksinimler

- Microsoft SQL Server 2016 veya üzeri
- SQL Server Management Studio (SSMS) veya Azure Data Studio
- .NET Framework 4.8
- Visual Studio 2019 veya üzeri (ASP.NET Web Forms desteği ile)

## Veritabanı Kurulum Adımları

### 1. SQL Script'i Çalıştırma

1. **SQL Server Management Studio**'yu açın
2. İlgili SQL Server örneğine bağlanın
3. `File > Open > File` menüsünden `Database/FMEADatabase.sql` dosyasını açın
4. Script'i çalıştırmak için **Execute** (F5) butonuna tıklayın

Script otomatik olarak:
- `FMEADatabase` veritabanını oluşturur
- Gerekli tabloları (`FMEAItems`, `Users`, `ActionHistory`) yaratır
- Görünümleri (Views) ve Stored Procedure'leri oluşturur
- 18 adet örnek FMEA kaydı ekler
- 8 adet örnek kullanıcı ekler

### 2. Veritabanı Yapısı

#### Tablolar

**FMEAItems** - Ana FMEA kayıtları tablosu
- `Id`: Birincil anahtar (Identity)
- `ProcessStep`: Proses adımı
- `FailureMode`: Hata modu
- `FailureEffect`: Hata etkisi
- `FailureCause`: Hata nedeni
- `Severity`: Şiddet (1-10)
- `Occurrence`: Oluşma olasılığı (1-10)
- `Detection`: Tespit edilebilirlik (1-10)
- `RPN`: Hesaplanmış kolon (Severity × Occurrence × Detection)
- `CurrentControls`: Mevcut kontroller
- `RecommendedActions`: Önerilen aksiyonlar
- `ResponsiblePerson`: Sorumlu kişi
- `TargetDate`: Hedef tarih
- `Status`: Durum (Açık, Kapalı, Devam Ediyor)
- `CreatedDate`: Oluşturma tarihi
- `ModifiedDate`: Güncelleme tarihi

**Users** - Kullanıcılar tablosu
- `Id`: Birincil anahtar
- `UserName`: Kullanıcı adı (benzersiz)
- `FullName`: Tam ad
- `Email`: E-posta
- `Department`: Departman
- `IsActive`: Aktiflik durumu
- `CreatedDate`: Oluşturma tarihi

**ActionHistory** - Aksiyon geçmişi tablosu
- `Id`: Birincil anahtar
- `FMEAItemId`: İlgili FMEA kaydı (Foreign Key)
- `ActionType`: Aksiyon tipi (Ekleme, Güncelleme, Silme)
- `OldValue`: Eski değer (JSON)
- `NewValue`: Yeni değer (JSON)
- `ChangedBy`: Değiştiren kişi
- `ChangedDate`: Değiştirme tarihi

#### Görünümler (Views)

- `vw_FMEARiskSummary`: Risk seviyesine göre özet
- `vw_FMEAStatusSummary`: Duruma göre özet
- `vw_ResponsiblePersonSummary`: Sorumlu kişilere göre dağılım
- `vw_OverdueActions`: Geciken aksiyonlar

#### Stored Procedure'ler

- `sp_AddFMEAItem`: Yeni FMEA kaydı ekleme
- `sp_UpdateFMEAItem`: FMEA kaydı güncelleme
- `sp_DeleteFMEAItem`: FMEA kaydı silme
- `sp_SearchFMEAItems`: FMEA kayıtlarını arama
- `sp_GetDashboardStatistics`: Dashboard istatistikleri

### 3. Connection String Ayarı

Web.config dosyasındaki connection string'i kendi SQL Server bilgilerinizle güncelleyin:

```xml
<connectionStrings>
  <add name="FMEAConnection" 
       connectionString="Data Source=YOUR_SERVER_NAME;Initial Catalog=FMEADatabase;Integrated Security=True;TrustServerCertificate=True;" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

**Alternatif Bağlantı Örnekleri:**

SQL Server Authentication ile:
```xml
<add name="FMEAConnection" 
     connectionString="Data Source=localhost;Initial Catalog=FMEADatabase;User Id=sa;Password=YourPassword;TrustServerCertificate=True;" 
     providerName="System.Data.SqlClient" />
```

Remote Server için:
```xml
<add name="FMEAConnection" 
     connectionString="Data Source=192.168.1.100\SQLEXPRESS;Initial Catalog=FMEADatabase;User Id=fmeauser;Password=YourPassword;TrustServerCertificate=True;" 
     providerName="System.Data.SqlClient" />
```

### 4. Örnek Veriler

Script çalıştırıldıktan sonra veritabanında aşağıdaki örnek veriler bulunacaktır:

#### FMEA Kayıtları (18 adet)

**Yüksek Riskli (RPN >= 200) - 5 kayıt:**
1. Montaj Hattı - Kaynak (RPN: 240)
2. CNC İşleme Merkezi (RPN: 224)
3. Boya Kabini (RPN: 140)
4. Kalite Kontrol (RPN: 216)
5. Isıl İşlem Fırını (RPN: 225)

**Orta Riskli (100 <= RPN < 200) - 6 kayıt:**
1. Paketleme (RPN: 54)
2. Pres Makinesi (RPN: 120)
3. Taşlama (RPN: 100)
4. Montaj (RPN: 112)
5. Enjeksiyon (RPN: 100)
6. Kaynak Robot Hücresi (RPN: 140)

**Düşük Riskli (RPN < 100) - 7 kayıt:**
1. Depo (RPN: 36)
2. Ofis (RPN: 36)
3. Sevkiyat (RPN: 24)
4. Bakım (RPN: 60)
5. Giriş Kalite (RPN: 32)
6. İnsan Kaynakları (RPN: 27)
7. Satın Alma (RPN: 30)
8. Enerji (RPN: 48)

#### Kullanıcılar (8 adet)
- Ahmet Yılmaz (Üretim)
- Ayşe Demir (Kalite Kontrol)
- Mehmet Kaya (Bakım)
- Fatma Şahin (Lojistik)
- Ali Veli (CNC Operasyon)
- Zeynep Çelik (Ar-Ge)
- Can Öztürk (İnsan Kaynakları)
- Elif Yıldız (Satın Alma)

### 5. Test Sorguları

Veritabanı kurulduktan sonra aşağıdaki sorguları çalıştırarak doğrulama yapabilirsiniz:

```sql
-- Toplam kayıt sayısı
SELECT COUNT(*) AS TotalRecords FROM FMEAItems;

-- Risk dağılımı
SELECT 
    CASE 
        WHEN RPN >= 200 THEN 'Yüksek Risk'
        WHEN RPN >= 100 THEN 'Orta Risk'
        ELSE 'Düşük Risk'
    END AS RiskLevel,
    COUNT(*) AS Count
FROM FMEAItems
GROUP BY 
    CASE 
        WHEN RPN >= 200 THEN 'Yüksek Risk'
        WHEN RPN >= 100 THEN 'Orta Risk'
        ELSE 'Düşük Risk'
    END;

-- En yüksek 5 RPN değeri
SELECT TOP 5 ProcessStep, FailureMode, RPN, ResponsiblePerson 
FROM FMEAItems 
ORDER BY RPN DESC;

-- Geciken aksiyonlar
SELECT * FROM vw_OverdueActions;

-- Dashboard istatistikleri
EXEC sp_GetDashboardStatistics;
```

### 6. Uygulamayı Çalıştırma

1. Visual Studio'da `FMEASystem.csproj` dosyasını açın
2. `Web.config` dosyasındaki connection string'in doğru olduğundan emin olun
3. Projeyi build edin (Build > Build Solution)
4. Uygulamayı çalıştırın (Debug > Start Debugging veya F5)
5. Tarayıcınızda FMEA sistemi açılacak ve veritabanındaki kayıtlar listelenecektir

## Sorun Giderme

### "Login failed for user" hatası
- SQL Server authentication modunu kontrol edin
- Kullanıcı yetkilerini doğrulayın
- Connection string'deki kullanıcı adı ve şifreyi kontrol edin

### "Invalid object name" hatası
- Script'in tam olarak çalıştırıldığından emin olun
- Doğru veritabanına bağlı olduğunuzu kontrol edin

### "Timeout expired" hatası
- Network bağlantısını kontrol edin
- SQL Server'ın çalıştığından emin olun
- Firewall ayarlarını kontrol edin

## Güvenlik Önerileri

1. Production ortamında Integrated Security yerine SQL Authentication kullanın
2. Connection string'leri şifreleyin
3. Minimum yetki prensibi ile veritabanı kullanıcıları oluşturun
4. Düzenli yedekleme planı oluşturun

## İletişim

Sorularınız için lütfen proje dokümantasyonunu inceleyin veya sistem yöneticinizle iletişime geçin.
