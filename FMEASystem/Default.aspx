<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>
<html lang="tr">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>FMEA Sistemi - Hata Türleri ve Etkileri Analizi</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />
    
    <style>
        body {
            background-color: #f8f9fa;
        }
        .header-bg {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
        }
        .card {
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
            margin-bottom: 1.5rem;
        }
        .card-header {
            background-color: #fff;
            border-bottom: 2px solid #667eea;
        }
        .rpn-high {
            background-color: #ffebee !important;
            color: #c62828;
            font-weight: bold;
        }
        .rpn-medium {
            background-color: #fff3e0 !important;
            color: #ef6c00;
            font-weight: bold;
        }
        .rpn-low {
            background-color: #e8f5e9 !important;
            color: #2e7d32;
        }
        .table-responsive {
            max-height: 600px;
            overflow-y: auto;
        }
        .btn-group-sm > .btn {
            padding: 0.25rem 0.5rem;
            font-size: 0.75rem;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        
        <!-- Header -->
        <div class="header-bg">
            <div class="container">
                <h1><i class="bi bi-shield-exclamation"></i> FMEA Sistemi</h1>
                <p class="lead mb-0">Hata Türleri ve Etkileri Analizi (Failure Mode and Effects Analysis)</p>
            </div>
        </div>

        <div class="container">
            
            <!-- İstatistik Kartları -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card text-white bg-primary">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-list-check"></i> Toplam Kayıt</h5>
                            <h2 class="mb-0" id="totalCount"><%= TotalCount %></h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-danger">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-exclamation-triangle"></i> Yüksek Risk</h5>
                            <h2 class="mb-0" id="highRiskCount"><%= HighRiskCount %></h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-warning">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-exclamation-circle"></i> Orta Risk</h5>
                            <h2 class="mb-0" id="mediumRiskCount"><%= MediumRiskCount %></h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card text-white bg-success">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-check-circle"></i> Düşük Risk</h5>
                            <h2 class="mb-0" id="lowRiskCount"><%= LowRiskCount %></h2>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Yeni Kayıt Ekleme Formu -->
            <div class="card">
                <div class="card-header">
                    <h4 class="mb-0"><i class="bi bi-plus-circle"></i> Yeni FMEA Kaydı Ekle</h4>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label for="txtProcessStep" class="form-label">Proses Adımı</label>
                            <asp:TextBox ID="txtProcessStep" CssClass="form-control" runat="server" placeholder="Proses adını giriniz"></asp:TextBox>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label for="txtFailureMode" class="form-label">Hata Modu</label>
                            <asp:TextBox ID="txtFailureMode" CssClass="form-control" runat="server" placeholder="Hata modunu giriniz"></asp:TextBox>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label for="txtFailureEffect" class="form-label">Hata Etkisi</label>
                            <asp:TextBox ID="txtFailureEffect" CssClass="form-control" runat="server" placeholder="Hata etkisini giriniz"></asp:TextBox>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label for="txtFailureCause" class="form-label">Hata Nedeni</label>
                            <asp:TextBox ID="txtFailureCause" CssClass="form-control" runat="server" placeholder="Hata nedenini giriniz"></asp:TextBox>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label for="txtCurrentControls" class="form-label">Mevcut Kontroller</label>
                            <asp:TextBox ID="txtCurrentControls" CssClass="form-control" runat="server" placeholder="Mevcut kontrolleri giriniz"></asp:TextBox>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label for="txtResponsiblePerson" class="form-label">Sorumlu Kişi</label>
                            <asp:TextBox ID="txtResponsiblePerson" CssClass="form-control" runat="server" placeholder="Sorumlu kişiyi giriniz"></asp:TextBox>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-3 mb-3">
                            <label for="ddlSeverity" class="form-label">Şiddet (S) <span class="text-muted">(1-10)</span></label>
                            <asp:DropDownList ID="ddlSeverity" CssClass="form-select" runat="server">
                                <asp:ListItem Value="1">1 - Önemsiz</asp:ListItem>
                                <asp:ListItem Value="2">2 - Çok Küçük</asp:ListItem>
                                <asp:ListItem Value="3">3 - Küçük</asp:ListItem>
                                <asp:ListItem Value="4">4 - Çok Düşük</asp:ListItem>
                                <asp:ListItem Value="5">5 - Orta</asp:ListItem>
                                <asp:ListItem Value="6">6 - Orta-Yüksek</asp:ListItem>
                                <asp:ListItem Value="7">7 - Yüksek</asp:ListItem>
                                <asp:ListItem Value="8">8 - Çok Yüksek</asp:ListItem>
                                <asp:ListItem Value="9">9 - Tehlikeli</asp:ListItem>
                                <asp:ListItem Value="10">10 - Çok Tehlikeli</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label for="ddlOccurrence" class="form-label">Oluşma (O) <span class="text-muted">(1-10)</span></label>
                            <asp:DropDownList ID="ddlOccurrence" CssClass="form-select" runat="server">
                                <asp:ListItem Value="1">1 - Çok Nadir</asp:ListItem>
                                <asp:ListItem Value="2">2 - Nadir</asp:ListItem>
                                <asp:ListItem Value="3">3 - Ara Sıra</asp:ListItem>
                                <asp:ListItem Value="4">4 - Bazen</asp:ListItem>
                                <asp:ListItem Value="5">5 - Orta</asp:ListItem>
                                <asp:ListItem Value="6">6 - Sık</asp:ListItem>
                                <asp:ListItem Value="7">7 - Çok Sık</asp:ListItem>
                                <asp:ListItem Value="8">8 - Neredeyse Her Zaman</asp:ListItem>
                                <asp:ListItem Value="9">9 - Sürekli</asp:ListItem>
                                <asp:ListItem Value="10">10 - Kesin</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label for="ddlDetection" class="form-label">Tespit (D) <span class="text-muted">(1-10)</span></label>
                            <asp:DropDownList ID="ddlDetection" CssClass="form-select" runat="server">
                                <asp:ListItem Value="1">1 - Kesin Tespit</asp:ListItem>
                                <asp:ListItem Value="2">2 - Çok Yüksek</asp:ListItem>
                                <asp:ListItem Value="3">3 - Yüksek</asp:ListItem>
                                <asp:ListItem Value="4">4 - İyi</asp:ListItem>
                                <asp:ListItem Value="5">5 - Orta</asp:ListItem>
                                <asp:ListItem Value="6">6 - Düşük</asp:ListItem>
                                <asp:ListItem Value="7">7 - Çok Düşük</asp:ListItem>
                                <asp:ListItem Value="8">8 - Zayıf</asp:ListItem>
                                <asp:ListItem Value="9">9 - Çok Zayıf</asp:ListItem>
                                <asp:ListItem Value="10">10 - Tespit Edilemez</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3 mb-3">
                            <label for="txtTargetDate" class="form-label">Hedef Tarih</label>
                            <asp:TextBox ID="txtTargetDate" CssClass="form-control" runat="server" TextMode="Date"></asp:TextBox>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12 mb-3">
                            <label for="txtRecommendedActions" class="form-label">Önerilen Aksiyonlar</label>
                            <asp:TextBox ID="txtRecommendedActions" CssClass="form-control" runat="server" TextMode="MultiLine" Rows="3" placeholder="Önerilen aksiyonları giriniz"></asp:TextBox>
                        </div>
                    </div>

                    <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                        <asp:Button ID="btnClear" CssClass="btn btn-secondary" runat="server" Text="Temizle" OnClick="btnClear_Click" />
                        <asp:Button ID="btnAdd" CssClass="btn btn-primary" runat="server" Text="Kaydet" OnClick="btnAdd_Click" />
                    </div>
                </div>
            </div>

            <!-- FMEA Tablosu -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h4 class="mb-0"><i class="bi bi-table"></i> FMEA Kayıtları</h4>
                    <div>
                        <asp:TextBox ID="txtSearch" CssClass="form-control form-control-sm d-inline-block" runat="server" placeholder="Ara..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                        <asp:Button ID="btnExport" CssClass="btn btn-success btn-sm ms-2" runat="server" Text="Excel'e Aktar" OnClick="btnExport_Click" />
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <asp:GridView ID="gvFMEA" CssClass="table table-hover table-bordered" runat="server" 
                            AutoGenerateColumns="False" AllowPaging="True" PageSize="10"
                            OnRowCommand="gvFMEA_RowCommand" OnRowDataBound="gvFMEA_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="Id" HeaderText="ID" ItemStyle-CssClass="align-middle" />
                                <asp:BoundField DataField="ProcessStep" HeaderText="Proses Adımı" ItemStyle-CssClass="align-middle" />
                                <asp:BoundField DataField="FailureMode" HeaderText="Hata Modu" ItemStyle-CssClass="align-middle" />
                                <asp:BoundField DataField="FailureEffect" HeaderText="Hata Etkisi" ItemStyle-CssClass="align-middle" />
                                <asp:TemplateField HeaderText="Şiddet (S)">
                                    <ItemTemplate>
                                        <span class="badge bg-secondary"><%# Eval("Severity") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Oluşma (O)">
                                    <ItemTemplate>
                                        <span class="badge bg-secondary"><%# Eval("Occurrence") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Tespit (D)">
                                    <ItemTemplate>
                                        <span class="badge bg-secondary"><%# Eval("Detection") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="RPN">
                                    <ItemTemplate>
                                        <span class="badge <%= GetRPNBadgeClass(Eval("RPN").ToString()) %>"><%# Eval("RPN") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="ResponsiblePerson" HeaderText="Sorumlu" ItemStyle-CssClass="align-middle" />
                                <asp:BoundField DataField="Status" HeaderText="Durum" ItemStyle-CssClass="align-middle">
                                    <ItemStyle CssClass="align-middle" />
                                </asp:BoundField>
                                <asp:TemplateField HeaderText="İşlemler" ItemStyle-Width="150">
                                    <ItemTemplate>
                                        <div class="btn-group btn-group-sm" role="group">
                                            <asp:LinkButton ID="lnkEdit" CssClass="btn btn-outline-primary" runat="server" CommandName="EditItem" CommandArgument='<%# Eval("Id") %>' Title="Düzenle">
                                                <i class="bi bi-pencil"></i>
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="lnkDelete" CssClass="btn btn-outline-danger" runat="server" CommandName="DeleteItem" CommandArgument='<%# Eval("Id") %>' Title="Sil" OnClientClick="return confirm('Bu kaydı silmek istediğinize emin misiniz?');">
                                                <i class="bi bi-trash"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <PagerStyle CssClass="pagination" />
                            <HeaderStyle CssClass="table-light" />
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- Modal: Düzenleme -->
            <div class="modal fade" id="editModal" tabindex="-1" aria-labelledby="editModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="editModalLabel">FMEA Kaydını Düzenle</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <asp:HiddenField ID="hfEditId" runat="server" />
                            <!-- Düzenleme form alanları buraya eklenebilir -->
                            <div class="alert alert-info">
                                <i class="bi bi-info-circle"></i> Düzenleme işlevi demo amaçlı eklenmemiştir. Gerçek uygulamada tüm alanlar burada düzenlenebilir.
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Kapat</button>
                            <asp:Button ID="btnUpdate" CssClass="btn btn-primary" runat="server" Text="Güncelle" />
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <!-- Footer -->
        <footer class="bg-dark text-white text-center py-3 mt-5">
            <div class="container">
                <p class="mb-0">&copy; 2024 FMEA Sistemi. Tüm hakları saklıdır.</p>
                <small>FMEA (Failure Mode and Effects Analysis) - Hata Türleri ve Etkileri Analizi</small>
            </div>
        </footer>

    </form>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <script type="text/javascript">
        // RPN renk kodlaması için client-side helper
        function highlightRPN() {
            var rpnCells = document.querySelectorAll('[id*="gvFMEA"] span.badge');
            rpnCells.forEach(function(cell) {
                var value = parseInt(cell.innerText);
                if (value >= 200) {
                    cell.classList.add('bg-danger');
                    cell.classList.remove('bg-warning', 'bg-success');
                } else if (value >= 100) {
                    cell.classList.add('bg-warning');
                    cell.classList.remove('bg-danger', 'bg-success');
                } else {
                    cell.classList.add('bg-success');
                    cell.classList.remove('bg-danger', 'bg-warning');
                }
            });
        }

        // Sayfa yüklendiğinde çalıştır
        document.addEventListener('DOMContentLoaded', function() {
            highlightRPN();
        });
    </script>
</body>
</html>
