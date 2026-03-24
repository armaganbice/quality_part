<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AccessDenied.aspx.cs" Inherits="FMEASystem.AccessDenied" %>

<!DOCTYPE html>
<html lang="tr">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Erişim Reddedildi</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet" />
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div class="container mt-5">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="card border-danger">
                        <div class="card-header bg-danger text-white text-center">
                            <h4><i class="bi bi-lock"></i> Erişim Reddedildi</h4>
                        </div>
                        <div class="card-body text-center">
                            <i class="bi bi-exclamation-triangle-fill text-danger" style="font-size: 4rem;"></i>
                            <h5 class="mt-3">Bu sayfaya erişim yetkiniz bulunmamaktadır.</h5>
                            <p class="text-muted">Lütfen sistem yöneticinizle iletişime geçin.</p>
                            <a href="Default.aspx" class="btn btn-primary mt-3">
                                <i class="bi bi-house"></i> Ana Sayfaya Dön
                            </a>
                            <a href="Logout.aspx" class="btn btn-outline-secondary mt-3 ms-2">
                                <i class="bi bi-box-arrow-right"></i> Çıkış Yap
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
