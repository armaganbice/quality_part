using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace FMEASystem.Helpers
{
    /// <summary>
    /// Kimlik doğrulama ve yetkilendirme yardımcı sınıfı
    /// </summary>
    public static class AuthenticationHelper
    {
        private const string SessionKey = "CurrentUser";
        private const string RoleSessionKey = "CurrentUserRole";

        /// <summary>
        /// Kullanıcı oturumda mı kontrol et
        /// </summary>
        public static bool IsAuthenticated(HttpContext context)
        {
            return context.Session[SessionKey] != null;
        }

        /// <summary>
        /// Oturum açmış kullanıcı adını al
        /// </summary>
        public static string GetCurrentUserName(HttpContext context)
        {
            return context.Session[SessionKey]?.ToString();
        }

        /// <summary>
        /// Kullanıcı rolünü al
        /// </summary>
        public static string GetUserRole(HttpContext context)
        {
            return context.Session[RoleSessionKey]?.ToString();
        }

        /// <summary>
        /// Kullanıcı oturumu başlat
        /// </summary>
        public static void Login(HttpContext context, string userName, string role)
        {
            context.Session[SessionKey] = userName;
            context.Session[RoleSessionKey] = role;
        }

        /// <summary>
        /// Kullanıcı oturumunu sonlandır
        /// </summary>
        public static void Logout(HttpContext context)
        {
            context.Session.Remove(SessionKey);
            context.Session.Remove(RoleSessionKey);
            context.Session.Abandon();
        }

        /// <summary>
        /// Şifreyi hash'le (SHA256)
        /// </summary>
        public static string HashPassword(string password)
        {
            using (var sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                foreach (byte b in bytes)
                {
                    builder.Append(b.ToString("x2"));
                }
                return builder.ToString();
            }
        }

        /// <summary>
        /// Şifre doğrula
        /// </summary>
        public static bool VerifyPassword(string password, string hashedPassword)
        {
            string hashedInput = HashPassword(password);
            return hashedInput.Equals(hashedPassword, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Rol bazlı erişim kontrolü
        /// </summary>
        public static bool HasPermission(HttpContext context, params string[] allowedRoles)
        {
            if (!IsAuthenticated(context))
                return false;

            string userRole = GetUserRole(context);
            foreach (string role in allowedRoles)
            {
                if (userRole == role)
                    return true;
            }
            return false;
        }

        /// <summary>
        /// Admin kontrolü
        /// </summary>
        public static bool IsAdmin(HttpContext context)
        {
            return HasPermission(context, "Admin");
        }

        /// <summary>
        /// Yönlendir - Yetki yoksa login sayfasına yönlendir
        /// </summary>
        public static void RequireAuthentication(HttpContext context)
        {
            if (!IsAuthenticated(context))
            {
                context.Response.Redirect("~/Login.aspx?returnUrl=" + 
                    HttpUtility.UrlEncode(context.Request.RawUrl));
            }
        }

        /// <summary>
        /// Yönlendir - Rol yetkisi yoksa erişim reddedildi sayfasına yönlendir
        /// </summary>
        public static void RequireRole(HttpContext context, params string[] allowedRoles)
        {
            RequireAuthentication(context);
            
            if (!HasPermission(context, allowedRoles))
            {
                context.Response.Redirect("~/AccessDenied.aspx");
            }
        }
    }
}
