using System;
using System.Data;
using System.Web.UI;
using FMEASystem.Helpers;
using FMEASystem.Models;

namespace FMEASystem
{
    public partial class Reports : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Kimlik doğrulama kontrolü
            AuthenticationHelper.RequireAuthentication(Context);

            if (!IsPostBack)
            {
                LoadDashboardData();
                LoadParetoAnalysis();
                LoadRiskDistribution();
                LoadTrendChart();
                LoadResponsiblePersonDistribution();
            }
        }

        /// <summary>
        /// Dashboard istatistiklerini yükle
        /// </summary>
        private void LoadDashboardData()
        {
            using (var conn = new System.Data.SqlClient.SqlConnection(
                System.Configuration.ConfigurationManager.ConnectionStrings["FMEAConnection"].ConnectionString))
            {
                string query = @"
                    SELECT 
                        COUNT(*) AS TotalItems,
                        SUM(CASE WHEN RPN >= 200 THEN 1 ELSE 0 END) AS HighRiskCount,
                        SUM(CASE WHEN RPN >= 100 AND RPN < 200 THEN 1 ELSE 0 END) AS MediumRiskCount,
                        SUM(CASE WHEN RPN < 100 THEN 1 ELSE 0 END) AS LowRiskCount,
                        AVG(RPN) AS AverageRPN
                    FROM FMEAItems";

                using (var cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    
                    if (reader.Read())
                    {
                        lblHighRiskCount.Text = reader["HighRiskCount"].ToString();
                        lblMediumRiskCount.Text = reader["MediumRiskCount"].ToString();
                        lblLowRiskCount.Text = reader["LowRiskCount"].ToString();
                        lblAverageRPN.Text = Convert.ToDecimal(reader["AverageRPN"]).ToString("N0");
                    }
                }
            }
        }

        /// <summary>
        /// Pareto analizini yükle
        /// </summary>
        private void LoadParetoAnalysis()
        {
            DataTable paretoData = ReportingHelper.GetParetoAnalysis();
            
            // Satır numarası ekle
            int rowNum = 1;
            foreach (DataRow row in paretoData.Rows)
            {
                row["RowNumber"] = rowNum++;
            }

            gvPareto.DataSource = paretoData;
            gvPareto.DataBind();

            // Pareto grafiği oluştur
            byte[] chartImage = ReportingHelper.CreateParetoChart(paretoData);
            imgParetoChart.ImageUrl = "data:image/png;base64," + Convert.ToBase64String(chartImage);
        }

        /// <summary>
        /// Risk dağılım pastasını yükle
        /// </summary>
        private void LoadRiskDistribution()
        {
            int highRisk = int.Parse(lblHighRiskCount.Text);
            int mediumRisk = int.Parse(lblMediumRiskCount.Text);
            int lowRisk = int.Parse(lblLowRiskCount.Text);

            byte[] pieChartImage = ReportingHelper.CreateRiskDistributionPieChart(highRisk, mediumRisk, lowRisk);
            imgRiskPieChart.ImageUrl = "data:image/png;base64," + Convert.ToBase64String(pieChartImage);
        }

        /// <summary>
        /// Trend grafiğini yükle
        /// </summary>
        private void LoadTrendChart()
        {
            // Basit bir trend grafiği placeholder
            // Gerçek uygulamada ReportingHelper.GetRiskTrend() kullanılabilir
            imgTrendChart.AlternateText = "Trend grafiği yakında eklenecek";
        }

        /// <summary>
        /// Sorumlu kişi dağılımını yükle
        /// </summary>
        private void LoadResponsiblePersonDistribution()
        {
            DataTable distribution = ReportingHelper.GetProcessRiskDistribution();
            
            // İlk 10 kaydı göster
            DataView view = new DataView(distribution);
            gvResponsiblePerson.DataSource = view.ToTable();
            gvResponsiblePerson.DataBind();
        }

        /// <summary>
        /// Excel export
        /// </summary>
        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            using (var conn = new System.Data.SqlClient.SqlConnection(
                System.Configuration.ConfigurationManager.ConnectionStrings["FMEAConnection"].ConnectionString))
            {
                string query = "SELECT * FROM FMEAItems ORDER BY RPN DESC";
                
                using (var cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ExcelExportHelper.ExportFMEAToExcel(Context, dt, $"FMEA_Raporu_{DateTime.Now:yyyyMMdd}.xlsx");
                }
            }
        }

        /// <summary>
        /// CSV export
        /// </summary>
        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            using (var conn = new System.Data.SqlClient.SqlConnection(
                System.Configuration.ConfigurationManager.ConnectionStrings["FMEAConnection"].ConnectionString))
            {
                string query = "SELECT * FROM FMEAItems ORDER BY RPN DESC";
                
                using (var cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ExcelExportHelper.ExportToCSV(Context, dt, $"FMEA_Raporu_{DateTime.Now:yyyyMMdd}.csv");
                }
            }
        }

        /// <summary>
        /// PDF export (HTML to PDF dönüşümü için iTextSharp veya benzeri kütüphane gerekli)
        /// </summary>
        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            string htmlContent = ReportingHelper.GeneratePDFReportHTML(Context);
            
            Response.Clear();
            Response.ContentType = "application/pdf";
            Response.AddHeader("Content-Disposition", $"attachment; filename=FMEA_Raporu_{DateTime.Now:yyyyMMdd}.pdf");
            
            // Not: Gerçek PDF oluşturmak için iTextSharp veya QuestPDF gibi kütüphane kullanılmalı
            // Bu demo için HTML içeriği gönderiyoruz
            Response.Write("<html><body>");
            Response.Write("<h2>PDF Rapor Özelliği</h2>");
            Response.Write("<p>Gerçek PDF oluşturma için iTextSharp veya QuestPDF kütüphanesi projeye eklenmelidir.</p>");
            Response.Write(htmlContent);
            Response.Write("</body></html>");
            Response.End();
        }
    }
}
