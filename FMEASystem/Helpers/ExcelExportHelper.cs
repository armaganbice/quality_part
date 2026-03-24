using System;
using System.Data;
using System.IO;
using System.Web;
using OfficeOpenXml;
using OfficeOpenXml.Style;

namespace FMEASystem.Helpers
{
    /// <summary>
    /// Excel export işlemleri için yardımcı sınıf (EPPlus kullanır)
    /// </summary>
    public static class ExcelExportHelper
    {
        /// <summary>
        /// FMEA verilerini Excel'e aktar
        /// </summary>
        public static void ExportFMEAToExcel(HttpContext context, DataTable dt, string fileName = "FMEA_Raporu.xlsx")
        {
            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;

            using (var package = new ExcelPackage())
            {
                var worksheet = package.Workbook.Worksheets.Add("FMEA Analizi");

                // Başlık satırı stilleri
                using (var headerRange = worksheet.Cells[1, 1, 1, dt.Columns.Count])
                {
                    headerRange.Style.Font.Bold = true;
                    headerRange.Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
                    headerRange.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(0, 112, 192));
                    headerRange.Style.Font.Color.SetColor(System.Drawing.Color.White);
                    headerRange.Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center;
                    headerRange.Style.VerticalAlignment = OfficeOpenXml.Style.ExcelVerticalAlignment.Center;
                }

                // Sütun başlıklarını yaz
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    worksheet.Cells[1, i + 1].Value = dt.Columns[i].ColumnName;
                }

                // Verileri yaz
                worksheet.Cells.LoadFromDataTable(dt, true);

                // Otomatik sütun genişliği
                worksheet.Cells[worksheet.Dimension.Address].AutoFitColumns();

                // RPN kolonunu bul ve renklendir
                int rpnColumnIndex = GetColumnIndex(dt, "RPN");
                if (rpnColumnIndex > 0)
                {
                    for (int row = 2; row <= worksheet.Dimension.Rows; row++)
                    {
                        var cell = worksheet.Cells[row, rpnColumnIndex];
                        if (cell.Value != null && int.TryParse(cell.Value.ToString(), out int rpn))
                        {
                            if (rpn >= 200)
                            {
                                cell.Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
                                cell.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(255, 200, 200));
                            }
                            else if (rpn >= 100)
                            {
                                cell.Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
                                cell.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(255, 255, 200));
                            }
                            else
                            {
                                cell.Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.Solid;
                                cell.Style.Fill.BackgroundColor.SetColor(System.Drawing.Color.FromArgb(200, 255, 200));
                            }
                        }
                    }
                }

                // Tablo kenarlıkları ekle
                using (var range = worksheet.Cells[1, 1, worksheet.Dimension.Rows, worksheet.Dimension.Columns])
                {
                    range.Style.Border.Top.Style = OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                    range.Style.Border.Bottom.Style = OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                    range.Style.Border.Left.Style = OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                    range.Style.Border.Right.Style = OfficeOpenXml.Style.ExcelBorderStyle.Thin;
                }

                // Sayfa başlığı ekle
                worksheet.InsertRow(0, 2);
                worksheet.Cells["A1"].Value = "FMEA (Failure Mode and Effects Analysis) Raporu";
                worksheet.Cells["A1"].Style.Font.Bold = true;
                worksheet.Cells["A1"].Style.Font.Size = 16;
                worksheet.Cells["A1"].Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Center;
                worksheet.MergeCells(1, 1, 1, dt.Columns.Count);

                worksheet.Cells["A2"].Value = $"Oluşturma Tarihi: {DateTime.Now:dd.MM.yyyy HH:mm}";
                worksheet.Cells["A2"].Style.HorizontalAlignment = OfficeOpenXml.Style.ExcelHorizontalAlignment.Right;
                worksheet.MergeCells(2, 1, 2, dt.Columns.Count);

                // HTTP response ile dosyayı gönder
                byte[] excelData = package.GetAsByteArray();
                context.Response.Clear();
                context.Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                context.Response.AddHeader("Content-Disposition", $"attachment; filename={fileName}");
                context.Response.BinaryWrite(excelData);
                context.Response.End();
            }
        }

        /// <summary>
        /// CSV formatında dışa aktar
        /// </summary>
        public static void ExportToCSV(HttpContext context, DataTable dt, string fileName = "FMEA_Raporu.csv")
        {
            var sb = new StringBuilder();

            // Sütun başlıkları
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                sb.Append(dt.Columns[i].ColumnName);
                if (i < dt.Columns.Count - 1)
                    sb.Append(";");
            }
            sb.AppendLine();

            // Veriler
            foreach (DataRow row in dt.Rows)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    string value = row[i].ToString().Replace(";", ",");
                    sb.Append(value);
                    if (i < dt.Columns.Count - 1)
                        sb.Append(";");
                }
                sb.AppendLine();
            }

            // HTTP response ile dosyayı gönder
            context.Response.Clear();
            context.Response.ContentType = "text/csv";
            context.Response.AddHeader("Content-Disposition", $"attachment; filename={fileName}");
            context.Response.Write(sb.ToString());
            context.Response.End();
        }

        /// <summary>
        /// Kolon indeksini bul
        /// </summary>
        private static int GetColumnIndex(DataTable dt, string columnName)
        {
            for (int i = 0; i < dt.Columns.Count; i++)
            {
                if (dt.Columns[i].ColumnName.Equals(columnName, StringComparison.OrdinalIgnoreCase))
                    return i + 1; // Excel 1-based indexing
            }
            return -1;
        }
    }
}
