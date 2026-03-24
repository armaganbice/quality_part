using System;
using System.Data;
using System.Data.SqlClient;

namespace FMEASystem.Models
{
    /// <summary>
    /// FMEA kayıt versiyon geçmişi için model
    /// </summary>
    public class FMEAVersion
    {
        public int VersionId { get; set; }
        public int FMEAItemId { get; set; }
        public string ActionType { get; set; } // Ekleme, Güncelleme, Silme
        public string OldValue { get; set; } // JSON formatında eski değer
        public string NewValue { get; set; } // JSON formatında yeni değer
        public string ChangedBy { get; set; }
        public DateTime ChangedDate { get; set; }
    }

    /// <summary>
    /// Düzenleme işlemleri için yardımcı sınıf
    /// </summary>
    public static class FMEAEditHelper
    {
        private static string ConnectionString => 
            System.Configuration.ConfigurationManager.ConnectionStrings["FMEAConnection"].ConnectionString;

        /// <summary>
        /// FMEA kaydını ID ile getir
        /// </summary>
        public static DataRow GetFMEAItemById(int id)
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
        /// FMEA kaydını güncelle
        /// </summary>
        public static bool UpdateFMEAItem(int id, FMEAItem item, string changedBy)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionString))
                {
                    string query = @"
                        UPDATE FMEAItems SET
                            ProcessStep = @ProcessStep,
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
                        WHERE Id = @Id";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", id);
                        cmd.Parameters.AddWithValue("@ProcessStep", item.ProcessStep);
                        cmd.Parameters.AddWithValue("@FailureMode", item.FailureMode);
                        cmd.Parameters.AddWithValue("@FailureEffect", item.FailureEffect);
                        cmd.Parameters.AddWithValue("@FailureCause", item.FailureCause);
                        cmd.Parameters.AddWithValue("@Severity", item.Severity);
                        cmd.Parameters.AddWithValue("@Occurrence", item.Occurrence);
                        cmd.Parameters.AddWithValue("@Detection", item.Detection);
                        cmd.Parameters.AddWithValue("@CurrentControls", (object)item.CurrentControls ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@RecommendedActions", (object)item.RecommendedActions ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ResponsiblePerson", (object)item.ResponsiblePerson ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@TargetDate", (object)item.TargetDate ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Status", item.Status);

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // Versiyon geçmişine kaydet
                            SaveVersionHistory(id, "Güncelleme", changedBy);
                            return true;
                        }
                    }
                }
                return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Güncelleme hatası: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Versiyon geçmişini getir
        /// </summary>
        public static DataTable GetVersionHistory(int fmeaItemId)
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = @"
                    SELECT Id AS VersionId, FMEAItemId, ActionType, OldValue, NewValue, ChangedBy, ChangedDate
                    FROM ActionHistory
                    WHERE FMEAItemId = @FMEAItemId
                    ORDER BY ChangedDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FMEAItemId", fmeaItemId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    return dt;
                }
            }
        }

        /// <summary>
        /// Versiyon geçmişine kaydet
        /// </summary>
        private static void SaveVersionHistory(int fmeaItemId, string actionType, string changedBy)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionString))
                {
                    // Eski ve yeni değerleri al
                    DataRow currentItem = GetFMEAItemById(fmeaItemId);
                    
                    string newValue = $"{{\"ProcessStep\": \"{currentItem["ProcessStep"]}\", \"FailureMode\": \"{currentItem["FailureMode"]}\", " +
                                     $"\"RPN\": {currentItem["RPN"]}, \"Status\": \"{currentItem["Status"]}\"}}";

                    string query = @"
                        INSERT INTO ActionHistory (FMEAItemId, ActionType, OldValue, NewValue, ChangedBy, ChangedDate)
                        VALUES (@FMEAItemId, @ActionType, @OldValue, @NewValue, @ChangedBy, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@FMEAItemId", fmeaItemId);
                        cmd.Parameters.AddWithValue("@ActionType", actionType);
                        cmd.Parameters.AddWithValue("@OldValue", DBNull.Value); // Basitlik için eski değer kaydedilmiyor
                        cmd.Parameters.AddWithValue("@NewValue", newValue);
                        cmd.Parameters.AddWithValue("@ChangedBy", changedBy);

                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Versiyon geçmişi kaydetme hatası: {ex.Message}");
            }
        }

        /// <summary>
        /// Kaydın kilidini kontrol et (başka biri düzenliyor mu?)
        /// </summary>
        public static bool IsRecordLocked(int fmeaItemId)
        {
            // Gerçek uygulamada distributed cache veya database lock mekanizması kullanılabilir
            // Bu demo için basit bir implementasyon
            return false;
        }

        /// <summary>
        /// Kaydı kilitle
        /// </summary>
        public static void LockRecord(int fmeaItemId, string userName)
        {
            // Gerçek uygulamada Redis veya SQL Server lock tabloları kullanılabilir
        }

        /// <summary>
        /// Kayıt kilidini kaldır
        /// </summary>
        public static void UnlockRecord(int fmeaItemId)
        {
            // Gerçek uygulamada lock temizleme işlemi
        }
    }
}
