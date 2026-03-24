/*
 * FMEA (Failure Mode and Effects Analysis) Sistemi
 * MS-SQL Veritabanı Oluşturma ve Örnek Veri Script'i
 * 
 * Kullanım: Bu script'i SQL Server Management Studio'da çalıştırın
 */

-- =============================================
-- Veritabanı Oluşturma
-- =============================================
USE master;
GO

-- Eğer veritabanı varsa sil (Dikkat: Tüm veriler silinir!)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'FMEADatabase')
BEGIN
    ALTER DATABASE FMEADatabase SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FMEADatabase;
END
GO

-- Yeni veritabanı oluştur
CREATE DATABASE FMEADatabase
COLLATE Turkish_CI_AS;
GO

USE FMEADatabase;
GO

-- =============================================
-- Tabloları Oluşturma
-- =============================================

-- FMEA Kayıtları Ana Tablosu
CREATE TABLE FMEAItems (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProcessStep NVARCHAR(200) NOT NULL,           -- Proses Adımı
    FailureMode NVARCHAR(300) NOT NULL,           -- Hata Modu
    FailureEffect NVARCHAR(500) NOT NULL,         -- Hata Etkisi
    FailureCause NVARCHAR(500) NOT NULL,          -- Hata Nedeni
    
    -- RPN (Risk Priority Number) Hesaplama Bileşenleri
    Severity INT NOT NULL CHECK (Severity BETWEEN 1 AND 10),      -- Şiddet (1-10)
    Occurrence INT NOT NULL CHECK (Occurrence BETWEEN 1 AND 10),  -- Oluşma Olasılığı (1-10)
    Detection INT NOT NULL CHECK (Detection BETWEEN 1 AND 10),    -- Tespit Edilebilirlik (1-10)
    
    -- RPN hesaplanmış kolon (Severity × Occurrence × Detection)
    RPN AS (Severity * Occurrence * Detection) PERSISTED,
    
    CurrentControls NVARCHAR(500),                -- Mevcut Kontroller
    RecommendedActions NVARCHAR(500),             -- Önerilen Aksiyonlar
    ResponsiblePerson NVARCHAR(100),              -- Sorumlu Kişi
    TargetDate DATE,                              -- Hedef Tarih
    Status NVARCHAR(50) DEFAULT 'Açık',           -- Durum (Açık, Kapalı, Devam Ediyor)
    
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    
    -- İndeksler
    INDEX IX_FMEAItems_RPN NONCLUSTERED (RPN DESC),
    INDEX IX_FMEAItems_Status NONCLUSTERED (Status),
    INDEX IX_FMEAItems_ProcessStep NONCLUSTERED (ProcessStep)
);
GO

-- Kullanıcılar Tablosu (Sorumlu kişiler için)
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL UNIQUE,
    FullName NVARCHAR(150) NOT NULL,
    Email NVARCHAR(150),
    Department NVARCHAR(100),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- Aksiyon Geçmişi Tablosu
CREATE TABLE ActionHistory (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FMEAItemId INT NOT NULL FOREIGN KEY REFERENCES FMEAItems(Id) ON DELETE CASCADE,
    ActionType NVARCHAR(50) NOT NULL,             -- Ekleme, Güncelleme, Silme
    OldValue NVARCHAR(MAX),                       -- Eski değer (JSON formatında)
    NewValue NVARCHAR(MAX),                       -- Yeni değer (JSON formatında)
    ChangedBy NVARCHAR(100),                      -- Değiştiren kişi
    ChangedDate DATETIME DEFAULT GETDATE()
);
GO

-- =============================================
-- Örnek Veri Ekleme
-- =============================================

-- Örnek Kullanıcılar
INSERT INTO Users (UserName, FullName, Email, Department) VALUES
('ahmet.yilmaz', 'Ahmet Yılmaz', 'ahmet.yilmaz@firma.com', 'Üretim'),
('ayse.demir', 'Ayşe Demir', 'ayse.demir@firma.com', 'Kalite Kontrol'),
('mehmet.kaya', 'Mehmet Kaya', 'mehmet.kaya@firma.com', 'Bakım'),
('fatma.sahin', 'Fatma Şahin', 'fatma.sahin@firma.com', 'Lojistik'),
('ali.veli', 'Ali Veli', 'ali.veli@firma.com', 'CNC Operasyon'),
('zeynep.celik', 'Zeynep Çelik', 'zeynep.celik@firma.com', 'Ar-Ge'),
('can.ozturk', 'Can Öztürk', 'can.ozturk@firma.com', 'İnsan Kaynakları'),
('elif.yildiz', 'Elif Yıldız', 'elif.yildiz@firma.com', 'Satın Alma');
GO

-- Örnek FMEA Kayıtları
INSERT INTO FMEAItems (ProcessStep, FailureMode, FailureEffect, FailureCause, 
                        Severity, Occurrence, Detection, CurrentControls, 
                        RecommendedActions, ResponsiblePerson, TargetDate, Status) VALUES

-- Yüksek Riskli Kayıtlar (RPN >= 200)
('Montaj Hattı - Kaynak', 'Kaynak dikişi zayıf', 'Ürün dayanıklılığı azalır, güvenlik riski oluşur', 'Kaynak akımı düşük, parametreler yanlış ayarlanmış',
 8, 6, 5, 'Görsel kontrol, periyodik tahribatlı test', 'Kaynak parametrelerini optimize et, otomatik kaynak sistemi kurulumu', 'Ahmet Yılmaz', DATEADD(DAY, 15, GETDATE()), 'Açık'),

('CNC İşleme Merkezi', 'Ölçü toleransı dışı üretim', 'Parça montaj uyumsuzluğu, ürün iadesi', 'Takım aşınması, kalibrasyon eksikliği',
 8, 7, 4, 'SPC kontrolü, ilk parça onayı', 'Takım değişim periyodunu kısalt, otomatik ölçüm sistemi ekle', 'Ali Veli', DATEADD(DAY, 7, GETDATE()), 'Açık'),

('Boya Kabini', 'Boya kalınlığı yetersiz', 'Korozyon riski artar, müşteri şikayeti', 'Püskürtme basıncı düşük, boya viskozitesi yanlış',
 7, 5, 4, 'Kalınlık ölçümü, yapışma testi', 'Basınç ayarlarını kontrol et, otomatik dozajlama sistemi kur', 'Ayşe Demir', DATEADD(DAY, 10, GETDATE()), 'Devam Ediyor'),

('Kalite Kontrol', 'Hatalı ürün geçişi', 'Müşteri şikayeti, marka itibarı zedelenir', 'Operatör hatası, dikkat dağınıklığı',
 9, 4, 6, 'Otomatik kontrol sistemi, çift kontrol', 'Operatör eğitimi, vision sistemi entegrasyonu', 'Mehmet Kaya', DATEADD(DAY, 20, GETDATE()), 'Açık'),

('Isıl İşlem Fırını', 'Sertlik değerleri standart dışı', 'Ürün performansı düşer, erken arıza', 'Fırın sıcaklık homojenitesi bozuk',
 9, 5, 5, 'Sertlik ölçümü, sıcaklık kayıtları', 'Fırın bakımı yap, termokupl kalibrasyonu', 'Ali Veli', DATEADD(DAY, 12, GETDATE()), 'Açık'),

-- Orta Riskli Kayıtlar (RPN 100-199)
('Paketleme', 'Etiket yanlış yapıştırma', 'Yanlış ürün sevkiyatı, müşteri memnuniyetsizliği', 'Manuel işlem hatası, yorgunluk',
 6, 3, 3, 'Çift kontrol, barkod okuyucu', 'Otomatik etiketleme sistemi yatırımı', 'Fatma Şahin', DATEADD(DAY, 30, GETDATE()), 'Kapalı'),

('Pres Makinesi', 'Çapak oluşumu', 'Sonraki operasyonlarda sorun, kalite kaybı', 'Kalıp aşınması, pres tonajı yetersiz',
 6, 5, 4, 'Görsel kontrol, çapak ölçümü', 'Kalıp bakımı, pres ayar optimizasyonu', 'Ahmet Yılmaz', DATEADD(DAY, 14, GETDATE()), 'Devam Ediyor'),

('Taşlama', 'Yüzey pürüzlülüğü yüksek', 'Montaj problemi, sızdırmazlık sorunu', 'Zımpara taşı aşınmış, ilerleme hızı yüksek',
 5, 4, 5, 'Profilometre ölçümü', 'Zımpara taşı değişim planı oluştur', 'Ali Veli', DATEADD(DAY, 10, GETDATE()), 'Açık'),

('Montaj', 'Vida torku yetersiz', 'Titreşim ile gevşeme, ürün arızası', 'Tork anahtarı kalibrasyonu bozuk',
 7, 4, 4, 'Tork kontrolü, son kontrol', 'Tork anahtarı kalibrasyonu, elektrikli tork sistemi', 'Mehmet Kaya', DATEADD(DAY, 5, GETDATE()), 'Açık'),

('Enjeksiyon', 'Çekme izi oluşumu', 'Görünüm hatası, boyut sapması', 'Soğutma süresi kısa, enjeksiyon basıncı düşük',
 5, 5, 4, 'Boyut kontrolü, görsel muayene', 'Proses parametrelerini optimize et', 'Zeynep Çelik', DATEADD(DAY, 18, GETDATE()), 'Devam Ediyor'),

('Kaynak Robot Hücresi', 'Pozisyon hatası', 'Kaynak dikişi yanlış konumda', 'Robot kalibrasyonu bozuk, fikstür aşınmış',
 7, 4, 5, 'Vision sistem kontrolü', 'Robot kalibrasyonu, fikstür yenileme', 'Ahmet Yılmaz', DATEADD(DAY, 25, GETDATE()), 'Açık'),

-- Düşük Riskli Kayıtlar (RPN < 100)
('Depo', 'Malzeme karışıklığı', 'Yanlış malzeme kullanımı', 'Etiketleme hatası, benzer kodlar',
 4, 3, 3, 'Barkod sistemi, FIFO uygulaması', 'RFID sistemine geçiş', 'Fatma Şahin', DATEADD(DAY, 45, GETDATE()), 'Kapalı'),

('Ofis', 'Doküman versiyon karışıklığı', 'Eski prosedür kullanımı', 'Doküman yönetim sistemi yok',
 3, 3, 4, 'Manuel kontrol', 'Elektronik doküman yönetim sistemi kurulumu', 'Elif Yıldız', DATEADD(DAY, 60, GETDATE()), 'Açık'),

('Sevkiyat', 'Ambalaj hasarı', 'Ürün hasarlı varış', 'Ambalaj malzemesi yetersiz',
 4, 2, 3, 'Görsel kontrol', 'Ambalaj standardı revizyonu', 'Fatma Şahin', DATEADD(DAY, 20, GETDATE()), 'Kapalı'),

('Bakım', 'Periyodik bakım gecikmesi', 'Planlanmamış duruşlar', 'Bakım planı takip edilmemiş',
 5, 3, 4, 'CMMS sistemi', 'Otomatik hatırlatma sistemi', 'Mehmet Kaya', DATEADD(DAY, 15, GETDATE()), 'Devam Ediyor'),

('Giriş Kalite', 'Numune alma hatası', 'Hatalı lot kabulü', 'Örnekleme planı yanlış uygulanmış',
 4, 2, 4, 'Talimat kontrolü', 'Örnekleme eğitimi, checklist uygulaması', 'Ayşe Demir', DATEADD(DAY, 10, GETDATE()), 'Açık'),

('İnsan Kaynakları', 'Eğitim takibi eksikliği', 'Yetkin olmayan personel görevlendirme', 'Eğitim kayıt sistemi yetersiz',
 3, 3, 3, 'Manuel takip', 'LMS sistemi entegrasyonu', 'Can Öztürk', DATEADD(DAY, 90, GETDATE()), 'Açık'),

('Satın Alma', 'Tedarikçi teslimat gecikmesi', 'Üretim aksaması', 'Tedarikçi performans takibi yok',
 5, 2, 3, 'Sipariş takibi', 'Tedarikçi değerlendirme sistemi', 'Elif Yıldız', DATEADD(DAY, 30, GETDATE()), 'Devam Ediyor'),

('Enerji', 'Kompresör basınç dalgalanması', 'Pnömatik sistem performans kaybı', 'Basınç regülatörü arızalı',
 4, 3, 4, 'Basınç göstergesi kontrolü', 'Regülatör değişimi, otomasyon ekleme', 'Mehmet Kaya', DATEADD(DAY, 7, GETDATE()), 'Açık');

GO

-- =============================================
-- Görünümler (Views)
-- =============================================

-- Risk Seviyesine Göre Özet Görünümü
CREATE VIEW vw_FMEARiskSummary AS
SELECT 
    CASE 
        WHEN RPN >= 200 THEN 'Yüksek Risk'
        WHEN RPN >= 100 THEN 'Orta Risk'
        ELSE 'Düşük Risk'
    END AS RiskLevel,
    COUNT(*) AS ItemCount,
    AVG(RPN) AS AverageRPN,
    MAX(RPN) AS MaxRPN,
    MIN(RPN) AS MinRPN
FROM FMEAItems
GROUP BY 
    CASE 
        WHEN RPN >= 200 THEN 'Yüksek Risk'
        WHEN RPN >= 100 THEN 'Orta Risk'
        ELSE 'Düşük Risk'
    END;
GO

-- Duruma Göre Özet Görünümü
CREATE VIEW vw_FMEAStatusSummary AS
SELECT 
    Status,
    COUNT(*) AS ItemCount,
    SUM(RPN) AS TotalRPN,
    AVG(RPN) AS AverageRPN
FROM FMEAItems
GROUP BY Status;
GO

-- Sorumlu Kişilere Göre Dağılım
CREATE VIEW vw_ResponsiblePersonSummary AS
SELECT 
    ResponsiblePerson,
    COUNT(*) AS AssignedCount,
    SUM(CASE WHEN Status = 'Açık' THEN 1 ELSE 0 END) AS OpenCount,
    SUM(CASE WHEN Status = 'Devam Ediyor' THEN 1 ELSE 0 END) AS InProgressCount,
    SUM(CASE WHEN Status = 'Kapalı' THEN 1 ELSE 0 END) AS ClosedCount,
    AVG(RPN) AS AverageRPN
FROM FMEAItems
GROUP BY ResponsiblePerson;
GO

-- Geciken Aksiyonlar Görünümü
CREATE VIEW vw_OverdueActions AS
SELECT 
    Id,
    ProcessStep,
    FailureMode,
    RPN,
    ResponsiblePerson,
    TargetDate,
    Status,
    DATEDIFF(DAY, TargetDate, GETDATE()) AS DaysOverdue
FROM FMEAItems
WHERE TargetDate < GETDATE() AND Status != 'Kapalı';
GO

-- =============================================
-- Stored Procedure'lar
-- =============================================

-- Yeni FMEA Kaydı Ekleme
CREATE PROCEDURE sp_AddFMEAItem
    @ProcessStep NVARCHAR(200),
    @FailureMode NVARCHAR(300),
    @FailureEffect NVARCHAR(500),
    @FailureCause NVARCHAR(500),
    @Severity INT,
    @Occurrence INT,
    @Detection INT,
    @CurrentControls NVARCHAR(500) = NULL,
    @RecommendedActions NVARCHAR(500) = NULL,
    @ResponsiblePerson NVARCHAR(100) = NULL,
    @TargetDate DATE = NULL,
    @Status NVARCHAR(50) = 'Açık',
    @NewId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO FMEAItems (ProcessStep, FailureMode, FailureEffect, FailureCause,
                           Severity, Occurrence, Detection, CurrentControls,
                           RecommendedActions, ResponsiblePerson, TargetDate, Status)
    VALUES (@ProcessStep, @FailureMode, @FailureEffect, @FailureCause,
            @Severity, @Occurrence, @Detection, @CurrentControls,
            @RecommendedActions, @ResponsiblePerson, @TargetDate, @Status);
    
    SET @NewId = SCOPE_IDENTITY();
    
    -- Aksiyon geçmişine kaydet
    INSERT INTO ActionHistory (FMEAItemId, ActionType, NewValue, ChangedBy)
    VALUES (@NewId, 'Ekleme', 
            (SELECT ProcessStep, FailureMode, RPN FROM FMEAItems WHERE Id = @NewId FOR JSON PATH),
            SYSTEM_USER);
END;
GO

-- FMEA Kaydı Güncelleme
CREATE PROCEDURE sp_UpdateFMEAItem
    @Id INT,
    @ProcessStep NVARCHAR(200),
    @FailureMode NVARCHAR(300),
    @FailureEffect NVARCHAR(500),
    @FailureCause NVARCHAR(500),
    @Severity INT,
    @Occurrence INT,
    @Detection INT,
    @CurrentControls NVARCHAR(500) = NULL,
    @RecommendedActions NVARCHAR(500) = NULL,
    @ResponsiblePerson NVARCHAR(100) = NULL,
    @TargetDate DATE = NULL,
    @Status NVARCHAR(50) = 'Açık'
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Eski değerleri kaydet
    DECLARE @OldValue NVARCHAR(MAX);
    SELECT @OldValue = (SELECT ProcessStep, FailureMode, Severity, Occurrence, Detection, RPN, Status
                        FROM FMEAItems WHERE Id = @Id FOR JSON PATH);
    
    UPDATE FMEAItems
    SET ProcessStep = @ProcessStep,
        FailureMode = @FailureMode,
        FailureEffect = @FailureEffect,
        FailureCause = @FailureCause,
        Severity = @Severity,
        Occurrence = @Occurrence,
        Detection = @Detection,
        CurrentControls = @CurrentControls,
        RecommendedActions = @RecommendedActions,
        ResponsiblePerson = @ResponsiblePerson,
        TargetDate = @TargetDate,
        Status = @Status,
        ModifiedDate = GETDATE()
    WHERE Id = @Id;
    
    -- Yeni değerleri kaydet
    DECLARE @NewValue NVARCHAR(MAX);
    SELECT @NewValue = (SELECT ProcessStep, FailureMode, Severity, Occurrence, Detection, RPN, Status
                        FROM FMEAItems WHERE Id = @Id FOR JSON PATH);
    
    -- Aksiyon geçmişine kaydet
    INSERT INTO ActionHistory (FMEAItemId, ActionType, OldValue, NewValue, ChangedBy)
    VALUES (@Id, 'Güncelleme', @OldValue, @NewValue, SYSTEM_USER);
END;
GO

-- FMEA Kaydı Silme
CREATE PROCEDURE sp_DeleteFMEAItem
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Aksiyon geçmişine kaydet
    INSERT INTO ActionHistory (FMEAItemId, ActionType, OldValue, ChangedBy)
    SELECT @Id, 'Silme', 
           (SELECT ProcessStep, FailureMode, RPN FROM FMEAItems WHERE Id = @Id FOR JSON PATH),
           SYSTEM_USER;
    
    DELETE FROM FMEAItems WHERE Id = @Id;
END;
GO

-- FMEA Kayıtlarını Arama
CREATE PROCEDURE sp_SearchFMEAItems
    @SearchTerm NVARCHAR(100) = NULL,
    @StatusFilter NVARCHAR(50) = NULL,
    @MinRPN INT = NULL,
    @MaxRPN INT = NULL,
    @ResponsiblePerson NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM FMEAItems
    WHERE (@SearchTerm IS NULL OR 
           ProcessStep LIKE '%' + @SearchTerm + '%' OR
           FailureMode LIKE '%' + @SearchTerm + '%' OR
           FailureEffect LIKE '%' + @SearchTerm + '%' OR
           ResponsiblePerson LIKE '%' + @SearchTerm + '%')
      AND (@StatusFilter IS NULL OR Status = @StatusFilter)
      AND (@MinRPN IS NULL OR RPN >= @MinRPN)
      AND (@MaxRPN IS NULL OR RPN <= @MaxRPN)
      AND (@ResponsiblePerson IS NULL OR ResponsiblePerson = @ResponsiblePerson)
    ORDER BY RPN DESC;
END;
GO

-- Dashboard İstatistikleri
CREATE PROCEDURE sp_GetDashboardStatistics
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Toplam kayıtlar
    SELECT COUNT(*) AS TotalItems FROM FMEAItems;
    
    -- Risk seviyelerine göre dağılım
    SELECT 
        SUM(CASE WHEN RPN >= 200 THEN 1 ELSE 0 END) AS HighRiskCount,
        SUM(CASE WHEN RPN >= 100 AND RPN < 200 THEN 1 ELSE 0 END) AS MediumRiskCount,
        SUM(CASE WHEN RPN < 100 THEN 1 ELSE 0 END) AS LowRiskCount
    FROM FMEAItems;
    
    -- Duruma göre dağılım
    SELECT 
        SUM(CASE WHEN Status = 'Açık' THEN 1 ELSE 0 END) AS OpenCount,
        SUM(CASE WHEN Status = 'Devam Ediyor' THEN 1 ELSE 0 END) AS InProgressCount,
        SUM(CASE WHEN Status = 'Kapalı' THEN 1 ELSE 0 END) AS ClosedCount
    FROM FMEAItems;
    
    -- Ortalama RPN değerleri
    SELECT 
        AVG(RPN) AS AverageRPN,
        MAX(RPN) AS MaxRPN,
        MIN(RPN) AS MinRPN
    FROM FMEAItems;
    
    -- Geciken aksiyon sayısı
    SELECT COUNT(*) AS OverdueCount 
    FROM FMEAItems 
    WHERE TargetDate < GETDATE() AND Status != 'Kapalı';
    
    -- En yüksek 5 RPN değeri
    SELECT TOP 5 Id, ProcessStep, FailureMode, RPN, ResponsiblePerson, Status
    FROM FMEAItems
    ORDER BY RPN DESC;
END;
GO

-- =============================================
-- Test Sorguları
-- =============================================

PRINT '=================================';
PRINT 'FMEA Veritabanı Başarıyla Oluşturuldu!';
PRINT '=================================';
PRINT '';

-- Toplam kayıt sayısı
SELECT 'Toplam FMEA Kayıt Sayısı:' AS Description, COUNT(*) AS Value FROM FMEAItems;

-- Risk seviyesi dağılımı
SELECT 'Yüksek Risk (RPN >= 200):' AS RiskLevel, COUNT(*) AS Count FROM FMEAItems WHERE RPN >= 200
UNION ALL
SELECT 'Orta Risk (100 <= RPN < 200):', COUNT(*) FROM FMEAItems WHERE RPN >= 100 AND RPN < 200
UNION ALL
SELECT 'Düşük Risk (RPN < 100):', COUNT(*) FROM FMEAItems WHERE RPN < 100;

-- Durum dağılımı
SELECT Status, COUNT(*) AS Count FROM FMEAItems GROUP BY Status;

-- En yüksek 5 RPN değeri
SELECT TOP 5 ProcessStep, FailureMode, RPN, ResponsiblePerson, Status 
FROM FMEAItems 
ORDER BY RPN DESC;

-- Geciken aksiyonlar
SELECT 'Geciken Aksiyon Sayısı:' AS Description, COUNT(*) AS Value 
FROM FMEAItems 
WHERE TargetDate < GETDATE() AND Status != 'Kapalı';

GO
