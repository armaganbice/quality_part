using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Web;
using System.Web.UI.DataVisualization.Charting;

namespace FMEASystem.Helpers
{
    /// <summary>
    /// Raporlama ve grafik oluşturma yardımcı sınıfı
    /// </summary>
    public static class ReportingHelper
    {
        private static string ConnectionString => 
            System.Configuration.ConfigurationManager.ConnectionStrings["FMEAConnection"].ConnectionString;

        /// <summary>
        /// Pareto analizi verilerini getir (80/20 kuralı)
        /// </summary>
        public static DataTable GetParetoAnalysis()
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = @"
                    SELECT TOP 10
                        FailureMode,
                        RPN,
                        Severity,
                        Occurrence,
                        Detection,
                        ProcessStep,
                        SUM(RPN) OVER (ORDER BY RPN DESC) AS CumulativeRPN,
                        (SELECT SUM(RPN) FROM FMEAItems) AS TotalRPN
                    FROM FMEAItems
                    ORDER BY RPN DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Yüzdelik hesaplama
                    foreach (DataRow row in dt.Rows)
                    {
                        decimal totalRpn = Convert.ToDecimal(row["TotalRPN"]);
                        decimal cumulativeRpn = Convert.ToDecimal(row["CumulativeRPN"]);
                        row["CumulativePercentage"] = (cumulativeRpn / totalRpn) * 100;
                    }

                    return dt;
                }
            }
        }

        /// <summary>
        /// Risk trend analizi (zamana göre)
        /// </summary>
        public static DataTable GetRiskTrend()
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = @"
                    SELECT 
                        YEAR(CreatedDate) AS Year,
                        MONTH(CreatedDate) AS Month,
                        COUNT(*) AS ItemCount,
                        AVG(RPN) AS AverageRPN,
                        SUM(CASE WHEN RPN >= 200 THEN 1 ELSE 0 END) AS HighRiskCount,
                        SUM(CASE WHEN RPN >= 100 AND RPN < 200 THEN 1 ELSE 0 END) AS MediumRiskCount,
                        SUM(CASE WHEN RPN < 100 THEN 1 ELSE 0 END) AS LowRiskCount
                    FROM FMEAItems
                    GROUP BY YEAR(CreatedDate), MONTH(CreatedDate)
                    ORDER BY Year, Month";

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
        /// Proses bazlı risk dağılımı
        /// </summary>
        public static DataTable GetProcessRiskDistribution()
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = @"
                    SELECT 
                        ProcessStep,
                        COUNT(*) AS ItemCount,
                        AVG(RPN) AS AverageRPN,
                        MAX(RPN) AS MaxRPN,
                        SUM(RPN) AS TotalRPN
                    FROM FMEAItems
                    GROUP BY ProcessStep
                    ORDER BY TotalRPN DESC";

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
        /// Pareto grafiği oluştur
        /// </summary>
        public static byte[] CreateParetoChart(DataTable dt)
        {
            using (var chart = new Chart())
            {
                chart.Width = 800;
                chart.Height = 600;

                var chartArea = new ChartArea("Main");
                chart.ChartAreas.Add(chartArea);

                // Sütun serisi (RPN değerleri)
                var columnSeries = new Series("RPN")
                {
                    ChartType = SeriesChartType.Column,
                    Color = Color.FromArgb(0, 112, 192),
                    IsValueShownAsLabel = true
                };

                // Çizgi serisi (Kümülatif yüzde)
                var lineSeries = new Series("Cumulative %")
                {
                    ChartType = SeriesChartType.Line,
                    Color = Color.Red,
                    BorderWidth = 3,
                    IsValueShownAsLabel = true,
                    YAxisType = AxisType.Secondary
                };

                chart.Series.Add(columnSeries);
                chart.Series.Add(lineSeries);

                // Verileri ekle
                foreach (DataRow row in dt.Rows)
                {
                    columnSeries.Points.AddXY(row["FailureMode"].ToString().Substring(0, Math.Min(15, row["FailureMode"].ToString().Length)), row["RPN"]);
                    
                    if (row.Table.Columns.Contains("CumulativePercentage"))
                    {
                        lineSeries.Points.AddXY(row["FailureMode"].ToString().Substring(0, Math.Min(15, row["FailureMode"].ToString().Length)), 
                            row["CumulativePercentage"]);
                    }
                }

                // Eksen ayarları
                chartArea.AxisX.Title = "Hata Modu";
                chartArea.AxisY.Title = "RPN Değeri";
                chartArea.AxisY.LabelStyle.Format = "N0";
                
                var secondaryAxis = new Axis("SecondaryY");
                secondaryAxis.Title = "Kümülatif %";
                secondaryAxis.Minimum = 0;
                secondaryAxis.Maximum = 100;
                chartArea.AxisY2 = secondaryAxis;

                // Başlık
                var title = new Title("Pareto Analizi - En Yüksek Riskli Hata Modları");
                title.Font = new Font("Arial", 14, FontStyle.Bold);
                chart.Titles.Add(title);

                // Legend
                var legend = new Legend("Legend1");
                chart.Legends.Add(legend);

                // Resmi byte array olarak döndür
                using (var ms = new MemoryStream())
                {
                    chart.SaveImage(ms, ChartImageFormat.Png);
                    return ms.ToArray();
                }
            }
        }

        /// <summary>
        /// Risk dağılım pastası oluştur
        /// </summary>
        public static byte[] CreateRiskDistributionPieChart(int highRisk, int mediumRisk, int lowRisk)
        {
            using (var chart = new Chart())
            {
                chart.Width = 600;
                chart.Height = 500;

                var chartArea = new ChartArea("Main");
                chart.ChartAreas.Add(chartArea);

                var series = new Series("RiskDistribution")
                {
                    ChartType = SeriesChartType.Pie,
                    IsValueShownAsLabel = true,
                    LabelFormat = "#,##0"
                };

                series.Points.AddXY("Yüksek Risk\n(RPN ≥ 200)", highRisk);
                series.Points.AddXY("Orta Risk\n(100 ≤ RPN < 200)", mediumRisk);
                series.Points.AddXY("Düşük Risk\n(RPN < 100)", lowRisk);

                // Renkler
                series.Points[0].Color = Color.FromArgb(220, 53, 69); // Kırmızı
                series.Points[1].Color = Color.FromArgb(255, 193, 7); // Sarı
                series.Points[2].Color = Color.FromArgb(40, 167, 69); // Yeşil

                chart.Series.Add(series);

                var title = new Title("Risk Seviyesi Dağılımı");
                title.Font = new Font("Arial", 14, FontStyle.Bold);
                chart.Titles.Add(title);

                using (var ms = new MemoryStream())
                {
                    chart.SaveImage(ms, ChartImageFormat.Png);
                    return ms.ToArray();
                }
            }
        }

        /// <summary>
        /// PDF raporu için HTML içeriği oluştur
        /// </summary>
        public static string GeneratePDFReportHTML(HttpContext context, string reportType = "Summary")
        {
            var html = new System.Text.StringBuilder();
            
            html.Append(@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body { font-family: Arial, sans-serif; }
        .header { text-align: center; margin-bottom: 30px; }
        .title { font-size: 24px; font-weight: bold; color: #0070C0; }
        .subtitle { font-size: 14px; color: #666; margin-top: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #0070C0; color: white; }
        .high-risk { background-color: #ffcccc; }
        .medium-risk { background-color: #ffffcc; }
        .low-risk { background-color: #ccffcc; }
        .stats-box { display: inline-block; margin: 10px; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .stat-value { font-size: 24px; font-weight: bold; }
        .stat-label { font-size: 12px; color: #666; }
    </style>
</head>
<body>
    <div class='header'>
        <div class='title'>FMEA Analiz Raporu</div>
        <div class='subtitle'>Oluşturma Tarihi: " + DateTime.Now.ToString("dd.MM.yyyy HH:mm") + @"</div>
    </div>
");

            // İstatistikleri ekle
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string statsQuery = @"
                    SELECT 
                        COUNT(*) AS TotalItems,
                        SUM(CASE WHEN RPN >= 200 THEN 1 ELSE 0 END) AS HighRiskCount,
                        SUM(CASE WHEN RPN >= 100 AND RPN < 200 THEN 1 ELSE 0 END) AS MediumRiskCount,
                        SUM(CASE WHEN RPN < 100 THEN 1 ELSE 0 END) AS LowRiskCount,
                        AVG(RPN) AS AverageRPN,
                        MAX(RPN) AS MaxRPN
                    FROM FMEAItems";

                using (SqlCommand cmd = new SqlCommand(statsQuery, conn))
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        html.Append("<div style='text-align:center;'>");
                        html.Append($"<div class='stats-box'><div class='stat-value'>{reader["TotalItems"]}</div><div class='stat-label'>Toplam Kayıt</div></div>");
                        html.Append($"<div class='stats-box'><div class='stat-value' style='color:red;'>{reader["HighRiskCount"]}</div><div class='stat-label'>Yüksek Risk</div></div>");
                        html.Append($"<div class='stats-box'><div class='stat-value' style='color:orange;'>{reader["MediumRiskCount"]}</div><div class='stat-label'>Orta Risk</div></div>");
                        html.Append($"<div class='stats-box'><div class='stat-value' style='color:green;'>{reader["LowRiskCount"]}</div><div class='stat-label'>Düşük Risk</div></div>");
                        html.Append($"<div class='stats-box'><div class='stat-value'>{reader["AverageRPN"]:N0}</div><div class='stat-label'>Ortalama RPN</div></div>");
                        html.Append($"<div class='stats-box'><div class='stat-value'>{reader["MaxRPN"]}</div><div class='stat-label'>Maksimum RPN</div></div>");
                        html.Append("</div>");
                    }
                    reader.Close();
                }
            }

            // En yüksek 10 risk tablosu
            html.Append("<h3>En Yüksek Riskli 10 Kayıt</h3>");
            html.Append("<table><thead><tr><th>Proses</th><th>Hata Modu</th><th>Şiddet</th><th>Oluşma</th><th>Tespit</th><th>RPN</th><th>Durum</th></tr></thead><tbody>");

            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string topRiskQuery = @"SELECT TOP 10 ProcessStep, FailureMode, Severity, Occurrence, Detection, RPN, Status 
                                        FROM FMEAItems ORDER BY RPN DESC";

                using (SqlCommand cmd = new SqlCommand(topRiskQuery, conn))
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        string riskClass = Convert.ToInt32(reader["RPN"]) >= 200 ? "high-risk" :
                                          Convert.ToInt32(reader["RPN"]) >= 100 ? "medium-risk" : "low-risk";
                        
                        html.Append($"<tr class='{riskClass}'>");
                        html.Append($"<td>{reader["ProcessStep"]}</td>");
                        html.Append($"<td>{reader["FailureMode"]}</td>");
                        html.Append($"<td>{reader["Severity"]}</td>");
                        html.Append($"<td>{reader["Occurrence"]}</td>");
                        html.Append($"<td>{reader["Detection"]}</td>");
                        html.Append($"<td><strong>{reader["RPN"]}</strong></td>");
                        html.Append($"<td>{reader["Status"]}</td>");
                        html.Append("</tr>");
                    }
                    reader.Close();
                }
            }

            html.Append("</tbody></table>");
            html.Append("</body></html>");

            return html.ToString();
        }
    }
}
