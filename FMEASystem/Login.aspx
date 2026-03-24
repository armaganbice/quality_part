<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="FMEASystem.Login" %>

<!DOCTYPE html>
<html lang="tr">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>FMEA Sistemi - Giriş Yap</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-container {
            max-width: 450px;
            width: 100%;
        }
        .login-card {
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        .login-header {
            background: #0070C0;
            color: white;
            padding: 30px;
            text-align: center;
        }
        .login-body {
            padding: 40px;
            background: white;
        }
        .form-control:focus {
            border-color: #0070C0;
            box-shadow: 0 0 0 0.2rem rgba(0, 112, 192, 0.25);
        }
        .btn-login {
            background: #0070C0;
            border: none;
            padding: 12px;
            font-weight: 600;
        }
        .btn-login:hover {
            background: #005a9e;
        }
        .demo-credentials {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <h2><i class="bi bi-shield-check"></i> FMEA Sistemi</h2>
                <p class="mb-0">Kullanıcı Girişi</p>
            </div>
            <div class="login-body">
                <form id="form1" runat="server">
                    <asp:ScriptManager ID="ScriptManager1" runat="server" />
                    
                    <div class="alert alert-danger" id="alertError" runat="server" visible="false">
                        <i class="bi bi-exclamation-triangle"></i>
                        <asp:Label ID="lblError" runat="server"></asp:Label>
                    </div>

                    <div class="mb-3">
                        <label for="txtUserName" class="form-label">Kullanıcı Adı</label>
                        <asp:TextBox ID="txtUserName" runat="server" CssClass="form-control" 
                            placeholder="Kullanıcı adınızı girin" required="required"></asp:TextBox>
                    </div>

                    <div class="mb-3">
                        <label for="txtPassword" class="form-label">Şifre</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" 
                            TextMode="Password" placeholder="Şifrenizi girin" required="required"></asp:TextBox>
                    </div>

                    <div class="mb-3 form-check">
                        <asp:CheckBox ID="chkRememberMe" runat="server" CssClass="form-check-input" />
                        <label class="form-check-label" for="chkRememberMe">Beni hatırla</label>
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Giriş Yap" 
                        CssClass="btn btn-primary btn-login w-100" 
                        OnClick="btnLogin_Click" />

                    <div class="demo-credentials">
                        <strong>Demo Kullanıcılar:</strong><br/>
                        <small>
                            Admin: admin / admin123<br/>
                            Yönetici: ayse.demir / demo123<br/>
                            Kullanıcı: ahmet.yilmaz / demo123
                        </small>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
