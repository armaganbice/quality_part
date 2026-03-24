using System;

namespace FMEASystem.Models
{
    /// <summary>
    /// FMEA (Failure Mode and Effects Analysis) öğesi için model sınıfı
    /// </summary>
    public class FMEAItem
    {
        public int Id { get; set; }
        public string ProcessStep { get; set; } // Proses Adımı
        public string FailureMode { get; set; } // Hata Modu
        public string FailureEffect { get; set; } // Hata Etkisi
        public string FailureCause { get; set; } // Hata Nedeni
        
        // RPN (Risk Priority Number) Hesaplama Bileşenleri
        public int Severity { get; set; } // Şiddet (1-10)
        public int Occurrence { get; set; } // Oluşma Olasılığı (1-10)
        public int Detection { get; set; } // Tespit Edilebilirlik (1-10)
        
        // RPN = Severity × Occurrence × Detection
        public int RPN => Severity * Occurrence * Detection;
        
        public string CurrentControls { get; set; } // Mevcut Kontroller
        public string RecommendedActions { get; set; } // Önerilen Aksiyonlar
        public string ResponsiblePerson { get; set; } // Sorumlu Kişi
        public DateTime? TargetDate { get; set; } // Hedef Tarih
        public string Status { get; set; } // Durum (Açık, Kapalı, Devam Ediyor)
        
        public FMEAItem()
        {
            Status = "Açık";
            CreatedDate = DateTime.Now;
        }
        
        public DateTime CreatedDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
    }
}
