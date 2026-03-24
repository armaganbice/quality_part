using System;

namespace FMEASystem.Models
{
    /// <summary>
    /// Kullanıcı yönetimi için model sınıfı
    /// </summary>
    public class User
    {
        public int Id { get; set; }
        public string UserName { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Department { get; set; }
        public string PasswordHash { get; set; }
        public string Role { get; set; } // Admin, Manager, User, Viewer
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? LastLoginDate { get; set; }
    }

    /// <summary>
    /// Kullanıcı rolleri
    /// </summary>
    public enum UserRole
    {
        Admin = 1,
        Manager = 2,
        User = 3,
        Viewer = 4
    }
}
