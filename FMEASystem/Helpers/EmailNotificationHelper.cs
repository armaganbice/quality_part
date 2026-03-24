using System;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Configuration;

namespace FMEASystem.Helpers
{
    /// <summary>
    /// E-posta bildirimleri için yardımcı sınıf
    /// </summary>
    public static class EmailNotificationHelper
    {
        private static string ConnectionString => 
            ConfigurationManager.ConnectionStrings["FMEAConnection"].ConnectionString;

        /// <summary>
        /// Hedef tarihi yaklaşan aksiyonlar için e-posta gönder
        /// </summary>
        public static void SendDueDateReminders()
        {
            // Yaklaşan hedef tarihleri bul (7 gün içinde)
            DataTable dueItems = GetUpcomingDueItems(7);

            foreach (DataRow row in dueItems.Rows)
            {
                string responsiblePerson = row["ResponsiblePerson"].ToString();
                string email = GetUserEmailByName(responsiblePerson);
                
                if (!string.IsNullOrEmpty(email))
                {
                    string subject = $"FMEA Aksiyon Hatırlatması - {row["ProcessStep"]}";
                    string body = GenerateEmailBody(row);
                    
                    SendEmail(email, subject, body);
                }
            }
        }

        /// <summary>
        /// Yüksek riskli yeni kayıt için bildirim gönder
        /// </summary>
        public static void SendHighRiskAlert(int fmeaItemId)
        {
            DataRow item = GetFMEAItemById(fmeaItemId);
            
            if (item != null && Convert.ToInt32(item["RPN"]) >= 200)
            {
                string subject = $"YÜKSEK RİSK Uyarısı - RPN: {item["RPN"]}";
                string body = GenerateHighRiskAlertBody(item);
                
                // Tüm yöneticilere gönder
                var managers = GetManagerEmails();
                foreach (string managerEmail in managers)
                {
                    SendEmail(managerEmail, subject, body);
                }
            }
        }

        /// <summary>
        /// Haftalık özet raporu gönder
        /// </summary>
        public static void SendWeeklySummaryReport()
        {
            DataTable summary = GetWeeklySummary();
            string subject = $"Haftalık FMEA Özet Raporu - {DateTime.Now:dd.MM.yyyy}";
            string body = GenerateWeeklyReportBody(summary);
            
            var allUsers = GetAllUserEmails();
            foreach (string email in allUsers)
            {
                SendEmail(email, subject, body);
            }
        }

        /// <summary>
        /// E-posta gönder
        /// </summary>
        private static void SendEmail(string to, string subject, string body)
        {
            try
            {
                // Web.config'den SMTP ayarlarını oku
                string smtpServer = ConfigurationManager.AppSettings["SMTPServer"] ?? "smtp.gmail.com";
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SMTPPort"] ?? "587");
                string senderEmail = ConfigurationManager.AppSettings["SenderEmail"] ?? "fmea@firma.com";
                string senderPassword = ConfigurationManager.AppSettings["SenderPassword"] ?? "";
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["SMTPEnableSSL"] ?? "true");

                using (var message = new MailMessage())
                {
                    message.From = new MailAddress(senderEmail, "FMEA Sistemi");
                    message.To.Add(to);
                    message.Subject = subject;
                    message.Body = body;
                    message.IsBodyHtml = true;

                    using (var client = new SmtpClient(smtpServer, smtpPort))
                    {
                        client.Credentials = new NetworkCredential(senderEmail, senderPassword);
                        client.EnableSsl = enableSsl;
                        client.Send(message);
                    }
                }
            }
            catch (Exception ex)
            {
                // Log hatayı
                System.Diagnostics.Debug.WriteLine($"E-posta gönderme hatası: {ex.Message}");
            }
        }

        /// <summary>
        /// Yaklaşan hedef tarihli kayıtları getir
        /// </summary>
        private static DataTable GetUpcomingDueItems(int daysAhead)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = @"
                    SELECT Id, ProcessStep, FailureMode, RPN, ResponsiblePerson, TargetDate, Status,
                           DATEDIFF(DAY, GETDATE(), TargetDate) AS DaysRemaining
                    FROM FMEAItems
                    WHERE TargetDate BETWEEN GETDATE() AND DATEADD(DAY, @DaysAhead, GETDATE())
                      AND Status != 'Kapalı'
                    ORDER BY TargetDate";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@DaysAhead", daysAhead);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
        }

        /// <summary>
        /// FMEA kaydını ID ile getir
        /// </summary>
        private static DataRow GetFMEAItemById(int id)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = "SELECT * FROM FMEAItems WHERE Id = @Id";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Id", id);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    
                    if (dt.Rows.Count > 0)
                        return dt.Rows[0];
                }
            }
            return null;
        }

        /// <summary>
        /// Kullanıcı adına göre e-posta adresini bul
        /// </summary>
        private static string GetUserEmailByName(string userName)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = "SELECT Email FROM Users WHERE FullName = @UserName";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserName", userName);
                    object result = cmd.ExecuteScalar();
                    return result?.ToString();
                }
            }
        }

        /// <summary>
        /// Yönetici e-posta adreslerini getir
        /// </summary>
        private static System.Collections.Generic.List<string> GetManagerEmails()
        {
            var emails = new System.Collections.Generic.List<string>();
            
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = "SELECT Email FROM Users WHERE Department IN ('Kalite Kontrol', 'Üretim') AND IsActive = 1";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        if (!string.IsNullOrEmpty(reader["Email"].ToString()))
                            emails.Add(reader["Email"].ToString());
                    }
                }
            }
            
            return emails;
        }

        /// <summary>
        /// Tüm kullanıcı e-posta adreslerini getir
        /// </summary>
        private static System.Collections.Generic.List<string> GetAllUserEmails()
        {
            var emails = new System.Collections.Generic.List<string>();
            
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = "SELECT Email FROM Users WHERE IsActive = 1 AND Email IS NOT NULL";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        if (!string.IsNullOrEmpty(reader["Email"].ToString()))
                            emails.Add(reader["Email"].ToString());
                    }
                }
            }
            
            return emails;
        }

        /// <summary>
        /// Haftalık özet verilerini getir
        /// </summary>
        private static DataTable GetWeeklySummary()
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = @"
                    SELECT 
                        COUNT(*) AS TotalItems,
                        SUM(CASE WHEN RPN >= 200 THEN 1 ELSE 0 END) AS HighRiskCount,
                        SUM(CASE WHEN RPN >= 100 AND RPN < 200 THEN 1 ELSE 0 END) AS MediumRiskCount,
                        SUM(CASE WHEN RPN < 100 THEN 1 ELSE 0 END) AS LowRiskCount,
                        SUM(CASE WHEN Status = 'Açık' THEN 1 ELSE 0 END) AS OpenCount,
                        SUM(CASE WHEN Status = 'Kapalı' THEN 1 ELSE 0 END) AS ClosedCountThisWeek,
                        AVG(RPN) AS AverageRPN
                    FROM FMEAItems
                    WHERE CreatedDate >= DATEADD(WEEK, -1, GETDATE())";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
        }

        /// <summary>
        /// E-posta içeriği oluştur (Hatırlatma)
        /// </summary>
        private static string GenerateEmailBody(DataRow row)
        {
            int daysRemaining = Convert.ToInt32(row["DaysRemaining"]);
            
            return $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; }}
        .header {{ background-color: #0070C0; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; }}
        .warning {{ background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 10px; margin: 10px 0; }}
        .danger {{ background-color: #f8d7da; border-left: 4px solid #dc3545; padding: 10px; margin: 10px 0; }}
        table {{ width: 100%; border-collapse: collapse; margin-top: 20px; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #0070C0; color: white; }}
        .footer {{ background-color: #f8f9fa; padding: 10px; text-align: center; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='header'>
        <h2>FMEA Aksiyon Hatırlatması</h2>
    </div>
    <div class='content'>
        <p>Sayın {row["ResponsiblePerson"]},</p>
        
        {(daysRemaining <= 3 ? 
            $"<div class='danger'><strong>DİKKAT:</strong> Aşağıdaki aksiyonun hedef tarihine sadece <strong>{daysRemaining} gün</strong> kaldı!</div>" :
            $"<div class='warning'><strong>HATIRLATMA:</strong> Aşağıdaki aksiyonun hedef tarihine <strong>{daysRemaining} gün</strong> kaldı.</div>")}
        
        <table>
            <tr><th>Proses Adımı</th><td>{row["ProcessStep"]}</td></tr>
            <tr><th>Hata Modu</th><td>{row["FailureMode"]}</td></tr>
            <tr><th>RPN Değeri</th><td><strong>{row["RPN"]}</strong></td></tr>
            <tr><th>Mevcut Durum</th><td>{row["Status"]}</td></tr>
            <tr><th>Hedef Tarih</th><td>{Convert.ToDateTime(row["TargetDate"]):dd.MM.yyyy}</td></tr>
        </table>
        
        <p>Lütfen gerekli aksiyonları zamanında tamamlayınız.</p>
        <p>İyi çalışmalar dileriz.<br/>FMEA Sistemi</p>
    </div>
    <div class='footer'>
        Bu e-posta otomatik olarak gönderilmiştir. Lütfen yanıtlamayınız.
    </div>
</body>
</html>";
        }

        /// <summary>
        /// Yüksek risk uyarı e-postası içeriği
        /// </summary>
        private static string GenerateHighRiskAlertBody(DataRow row)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; }}
        .header {{ background-color: #dc3545; color: white; padding: 20px; text-align: center; }}
        .alert-box {{ background-color: #f8d7da; border: 2px solid #dc3545; padding: 20px; margin: 20px 0; }}
        table {{ width: 100%; border-collapse: collapse; margin-top: 20px; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #0070C0; color: white; }}
    </style>
</head>
<body>
    <div class='header'>
        <h1>⚠️ YÜKSEK RİSK UYARISI ⚠️</h1>
    </div>
    <div class='alert-box'>
        <h2>Yeni yüksek riskli bir FMEA kaydı oluşturuldu!</h2>
        <p><strong>RPN Değeri: {row["RPN"]} (≥ 200)</strong></p>
    </div>
    <table>
        <tr><th>Proses Adımı</th><td>{row["ProcessStep"]}</td></tr>
        <tr><th>Hata Modu</th><td>{row["FailureMode"]}</td></tr>
        <tr><th>Hata Etkisi</th><td>{row["FailureEffect"]}</td></tr>
        <tr><th>Hata Nedeni</th><td>{row["FailureCause"]}</td></tr>
        <tr><th>Şiddet / Oluşma / Tespit</th><td>{row["Severity"]} / {row["Occurrence"]} / {row["Detection"]}</td></tr>
        <tr><th>Sorumlu Kişi</th><td>{row["ResponsiblePerson"]}</td></tr>
        <tr><th>Oluşturulma Tarihi</th><td>{Convert.ToDateTime(row["CreatedDate"]):dd.MM.yyyy HH:mm}</td></tr>
    </table>
    <p style='margin-top: 20px;'>Lütfen bu riski azaltmak için acil aksiyon planı oluşturunuz.</p>
</body>
</html>";
        }

        /// <summary>
        /// Haftalık rapor e-postası içeriği
        /// </summary>
        private static string GenerateWeeklyReportBody(DataTable summary)
        {
            if (summary.Rows.Count == 0)
                return "<p>Bu hafta yeni kayıt bulunmamaktadır.</p>";

            DataRow row = summary.Rows[0];
            
            return $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; }}
        .header {{ background-color: #0070C0; color: white; padding: 20px; text-align: center; }}
        .stats {{ display: flex; justify-content: space-around; margin: 20px 0; }}
        .stat-box {{ text-align: center; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }}
        .stat-value {{ font-size: 24px; font-weight: bold; }}
        .stat-label {{ font-size: 12px; color: #666; }}
    </style>
</head>
<body>
    <div class='header'>
        <h2>Haftalık FMEA Özet Raporu</h2>
        <p>{DateTime.Now.AddDays(-7):dd.MM.yyyy} - {DateTime.Now:dd.MM.yyyy}</p>
    </div>
    <div class='stats'>
        <div class='stat-box'>
            <div class='stat-value'>{row["TotalItems"]}</div>
            <div class='stat-label'>Yeni Kayıt</div>
        </div>
        <div class='stat-box'>
            <div class='stat-value' style='color:red;'>{row["HighRiskCount"]}</div>
            <div class='stat-label'>Yüksek Risk</div>
        </div>
        <div class='stat-box'>
            <div class='stat-value' style='color:orange;'>{row["MediumRiskCount"]}</div>
            <div class='stat-label'>Orta Risk</div>
        </div>
        <div class='stat-box'>
            <div class='stat-value' style='color:green;'>{row["LowRiskCount"]}</div>
            <div class='stat-label'>Düşük Risk</div>
        </div>
        <div class='stat-box'>
            <div class='stat-value'>{row["AverageRPN"]:N0}</div>
            <div class='stat-label'>Ortalama RPN</div>
        </div>
    </div>
    <p>Bu rapor FMEA sistemi tarafından otomatik olarak oluşturulmuştur.</p>
</body>
</html>";
        }
    }
}
