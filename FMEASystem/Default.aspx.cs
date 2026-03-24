using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using FMEASystem.Models;

public partial class _Default : Page
{
    private string ConnectionString => ConfigurationManager.ConnectionStrings["FMEAConnection"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindGridView();
            UpdateStatistics();
        }
    }

    /// <summary>
    /// GridView'i veri ile doldur
    /// </summary>
    private void BindGridView()
    {
        using (SqlConnection conn = new SqlConnection(ConnectionString))
        {
            string query = @"SELECT * FROM FMEAItems WHERE 1=1";
            
            if (!string.IsNullOrEmpty(txtSearch.Text))
            {
                query += " AND (ProcessStep LIKE @Search OR FailureMode LIKE @Search OR ResponsiblePerson LIKE @Search)";
            }
            
            query += " ORDER BY RPN DESC";
            
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                if (!string.IsNullOrEmpty(txtSearch.Text))
                {
                    cmd.Parameters.AddWithValue("@Search", "%" + txtSearch.Text + "%");
                }
                
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                
                gvFMEA.DataSource = dt;
                gvFMEA.DataBind();
            }
        }
    }

    /// <summary>
    /// İstatistikleri güncelle
    /// </summary>
    private void UpdateStatistics()
    {
        using (SqlConnection conn = new SqlConnection(ConnectionString))
        {
            string query = @"
                SELECT 
                    COUNT(*) AS TotalItems,
                    SUM(CASE WHEN RPN >= 200 THEN 1 ELSE 0 END) AS HighRiskCount,
                    SUM(CASE WHEN RPN >= 100 AND RPN < 200 THEN 1 ELSE 0 END) AS MediumRiskCount,
                    SUM(CASE WHEN RPN < 100 THEN 1 ELSE 0 END) AS LowRiskCount
                FROM FMEAItems";
            
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();
                
                if (reader.Read())
                {
                    TotalCount = reader.GetInt32(0);
                    HighRiskCount = reader.GetInt32(1);
                    MediumRiskCount = reader.GetInt32(2);
                    LowRiskCount = reader.GetInt32(3);
                }
                
                reader.Close();
            }
        }
    }

    // Public properties for statistics display
    public int TotalCount { get; set; }
    public int HighRiskCount { get; set; }
    public int MediumRiskCount { get; set; }
    public int LowRiskCount { get; set; }

    /// <summary>
    /// RPN değerine göre badge CSS sınıfı döndür
    /// </summary>
    protected string GetRPNBadgeClass(string rpnValue)
    {
        if (int.TryParse(rpnValue, out int rpn))
        {
            if (rpn >= 200) return "bg-danger";
            if (rpn >= 100) return "bg-warning text-dark";
            return "bg-success";
        }
        return "bg-secondary";
    }

    /// <summary>
    /// Kaydet butonu tıklama eventi
    /// </summary>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = @"
                    INSERT INTO FMEAItems (ProcessStep, FailureMode, FailureEffect, FailureCause,
                                           Severity, Occurrence, Detection, CurrentControls,
                                           RecommendedActions, ResponsiblePerson, TargetDate, Status)
                    VALUES (@ProcessStep, @FailureMode, @FailureEffect, @FailureCause,
                            @Severity, @Occurrence, @Detection, @CurrentControls,
                            @RecommendedActions, @ResponsiblePerson, @TargetDate, @Status)";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ProcessStep", txtProcessStep.Text.Trim());
                    cmd.Parameters.AddWithValue("@FailureMode", txtFailureMode.Text.Trim());
                    cmd.Parameters.AddWithValue("@FailureEffect", txtFailureEffect.Text.Trim());
                    cmd.Parameters.AddWithValue("@FailureCause", txtFailureCause.Text.Trim());
                    cmd.Parameters.AddWithValue("@Severity", int.Parse(ddlSeverity.SelectedValue));
                    cmd.Parameters.AddWithValue("@Occurrence", int.Parse(ddlOccurrence.SelectedValue));
                    cmd.Parameters.AddWithValue("@Detection", int.Parse(ddlDetection.SelectedValue));
                    cmd.Parameters.AddWithValue("@CurrentControls", string.IsNullOrEmpty(txtCurrentControls.Text) ? (object)DBNull.Value : txtCurrentControls.Text.Trim());
                    cmd.Parameters.AddWithValue("@RecommendedActions", string.IsNullOrEmpty(txtRecommendedActions.Text) ? (object)DBNull.Value : txtRecommendedActions.Text.Trim());
                    cmd.Parameters.AddWithValue("@ResponsiblePerson", string.IsNullOrEmpty(txtResponsiblePerson.Text) ? (object)DBNull.Value : txtResponsiblePerson.Text.Trim());
                    
                    if (!string.IsNullOrEmpty(txtTargetDate.Text))
                    {
                        cmd.Parameters.AddWithValue("@TargetDate", DateTime.Parse(txtTargetDate.Text));
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@TargetDate", DBNull.Value);
                    }
                    
                    cmd.Parameters.AddWithValue("@Status", "Açık");
                    
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            
            // Formu temizle
            ClearForm();
            
            // Tabloyu yenile
            BindGridView();
            UpdateStatistics();

            // Başarı mesajı göster
            ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess", 
                "alert('FMEA kaydı başarıyla eklendi!');", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "showError", 
                $"alert('Hata: {ex.Message}');", true);
        }
    }

    /// <summary>
    /// Temizle butonu tıklama eventi
    /// </summary>
    protected void btnClear_Click(object sender, EventArgs e)
    {
        ClearForm();
    }

    /// <summary>
    /// Form alanlarını temizle
    /// </summary>
    private void ClearForm()
    {
        txtProcessStep.Text = "";
        txtFailureMode.Text = "";
        txtFailureEffect.Text = "";
        txtFailureCause.Text = "";
        txtCurrentControls.Text = "";
        txtRecommendedActions.Text = "";
        txtResponsiblePerson.Text = "";
        txtTargetDate.Text = "";
        ddlSeverity.SelectedIndex = 0;
        ddlOccurrence.SelectedIndex = 0;
        ddlDetection.SelectedIndex = 0;
    }

    /// <summary>
    /// Arama kutusu değişiklik eventi
    /// </summary>
    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        BindGridView();
    }

    /// <summary>
    /// GridView satır komutları (Sil, Düzenle)
    /// </summary>
    protected void gvFMEA_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "DeleteItem")
        {
            int id = int.Parse(e.CommandArgument.ToString());
            
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = "DELETE FROM FMEAItems WHERE Id = @Id";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Id", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            
            BindGridView();
            UpdateStatistics();
            
            ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess", 
                "alert('Kayıt başarıyla silindi!');", true);
        }
        else if (e.CommandName == "EditItem")
        {
            int id = int.Parse(e.CommandArgument.ToString());
            hfEditId.Value = id.ToString();
            
            // Modal'ı açmak için JavaScript
            ScriptManager.RegisterStartupScript(this, GetType(), "openEditModal", 
                "var editModal = new bootstrap.Modal(document.getElementById('editModal')); editModal.show();", true);
        }
    }

    /// <summary>
    /// GridView satır bağlama eventi (RPN renklendirme vb.)
    /// </summary>
    protected void gvFMEA_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView row = (DataRowView)e.Row.DataItem;
            
            // Durum badge renklendirme
            var statusCell = e.Row.Cells[9]; // Status kolonu
            string status = row["Status"].ToString();
            
            if (status == "Açık")
            {
                statusCell.ForeColor = System.Drawing.Color.Red;
                statusCell.Font.Bold = true;
            }
            else if (status == "Kapalı")
            {
                statusCell.ForeColor = System.Drawing.Color.Green;
            }
            else if (status == "Devam Ediyor")
            {
                statusCell.ForeColor = System.Drawing.Color.Orange;
            }

            // Yüksek RPN değerlerini vurgula
            int rpn = Convert.ToInt32(row["RPN"]);
            if (rpn >= 200)
            {
                e.Row.CssClass = "table-danger";
            }
        }
    }

    /// <summary>
    /// Excel'e aktarma butonu (Demo)
    /// </summary>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        // Gerçek uygulamada Excel export implementasyonu buraya eklenebilir
        ScriptManager.RegisterStartupScript(this, GetType(), "showInfo", 
            "alert('Excel export özelliği demo versiyonda aktif değildir.\\n\\nGerçek uygulamada:\\n- EPPlus veya ClosedXML kütüphanesi kullanılabilir\\n- CSV formatında dışa aktarım yapılabilir');", true);
    }
}
