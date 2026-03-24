using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using FMEASystem.Helpers;

namespace FMEASystem
{
    public partial class Login : Page
    {
        private string ConnectionString => ConfigurationManager.ConnectionStrings["FMEAConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Zaten giriş yapılmışsa ana sayfaya yönlendir
            if (AuthenticationHelper.IsAuthenticated(Context))
            {
                Response.Redirect("~/Default.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string userName = txtUserName.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (ValidateUser(userName, password, out string role, out string fullName))
            {
                // Oturum başlat
                AuthenticationHelper.Login(Context, userName, role);

                // Son giriş tarihini güncelle
                UpdateLastLoginDate(userName);

                // Ana sayfaya yönlendir
                Response.Redirect("~/Default.aspx");
            }
            else
            {
                // Hata mesajı göster
                alertError.Visible = true;
                lblError.Text = "Kullanıcı adı veya şifre hatalı!";
            }
        }

        /// <summary>
        /// Kullanıcıyı doğrula
        /// </summary>
        private bool ValidateUser(string userName, string password, out string role, out string fullName)
        {
            role = "";
            fullName = "";

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionString))
                {
                    // Demo için basit doğrulama
                    // Gerçek uygulamada şifre hash'lenmiş olmalı
                    string query = @"
                        SELECT Id, UserName, FullName, Email, Department, 
                               CASE 
                                   WHEN Department IN ('Kalite Kontrol', 'Üretim') THEN 'Manager'
                                   WHEN Department = 'İnsan Kaynakları' THEN 'Admin'
                                   ELSE 'User'
                               END AS Role
                        FROM Users 
                        WHERE UserName = @UserName AND IsActive = 1";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserName", userName);
                        
                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();

                        if (reader.Read())
                        {
                            // Demo amaçlı basit şifre kontrolü
                            // Gerçek uygulamada: AuthenticationHelper.VerifyPassword(password, reader["PasswordHash"].ToString())
                            string demoPassword = userName == "admin" ? "admin123" : "demo123";
                            
                            if (password == demoPassword)
                            {
                                role = reader["Role"].ToString();
                                fullName = reader["FullName"].ToString();
                                return true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Giriş hatası: {ex.Message}");
            }

            return false;
        }

        /// <summary>
        /// Son giriş tarihini güncelle
        /// </summary>
        private void UpdateLastLoginDate(string userName)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionString))
                {
                    string query = "UPDATE Users SET LastLoginDate = GETDATE() WHERE UserName = @UserName";
                    
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserName", userName);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Son giriş güncelleme hatası: {ex.Message}");
            }
        }
    }
}
