using System;
using System.Web.UI;
using FMEASystem.Helpers;

namespace FMEASystem
{
    public partial class Logout : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Oturumu sonlandır
            AuthenticationHelper.Logout(Context);
            
            // Login sayfasına yönlendir
            Response.Redirect("~/Login.aspx");
        }
    }
}
