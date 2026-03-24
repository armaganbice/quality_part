<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="FMEASystem.Reports" %>

<!DOCTYPE html>
<html lang="tr">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>FMEA Sistemi - Raporlar ve Analizler</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        .chart-container { 
            position: relative; 
            height: 400px; 
            margin-bottom: 30px;
        }
        .stat-card {
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-5px);
        }
        .pareto-table td, .pareto-table th {
            vertical-align: middle;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <!-- Navbar -->
        <nav class="navbar navbar-expand-lg navbar-dark bg-primary mb-4">
            <div class="container-fluid">
                <a class="navbar-brand" href="Default.aspx"><i class="bi bi-shield-check"></i> FMEA Sistemi</a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav me-auto">
                        <li class="nav-item">
                            <a class="nav-link" href="Default.aspx"><i class="bi bi-house"></i> Ana Sayfa</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link active" href="Reports.aspx"><i class="bi bi-graph-up"></i> Raporlar</a>
                        </li>
                    </ul>
                    <ul class="navbar-nav">
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" id="exportDropdown" role="button" data-bs-toggle="dropdown">
                                <i class="bi bi-download"></i> Dışa Aktar
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="#" onclick="__doPostBack('btnExportExcel', '')">
                                    <i class="bi bi-file-earmark-excel"></i> Excel (EPPlus)
                                </a></li>
                                <li><a class="dropdown-item" href="#" onclick="__doPostBack('btnExportCSV', '')">
                                    <i class="bi bi-filetype-csv"></i> CSV
                                </a></li>
                                <li><hr class="dropdown-divider"/></li>
                                <li><a class="dropdown-item" href="#" onclick="__doPostBack('btnExportPDF', '')">
                                    <i class="bi bi-file-earmark-pdf"></i> PDF Raporu
                                </a></li>
                            </ul>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="Logout.aspx"><i class="bi bi-box-arrow-right"></i> Çıkış</a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>

        <div class="container-fluid">
            <!-- İstatistik Kartları -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card stat-card bg-danger text-white">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-exclamation-triangle"></i> Yüksek Risk</h5>
                            <h2 class="mb-0"><asp:Label ID="lblHighRiskCount" runat="server" Text="0"></asp:Label></h2>
                            <small>RPN ≥ 200</small>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card bg-warning text-dark">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-exclamation-circle"></i> Orta Risk</h5>
                            <h2 class="mb-0"><asp:Label ID="lblMediumRiskCount" runat="server" Text="0"></asp:Label></h2>
                            <small>100 ≤ RPN < 200</small>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card bg-success text-white">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-check-circle"></i> Düşük Risk</h5>
                            <h2 class="mb-0"><asp:Label ID="lblLowRiskCount" runat="server" Text="0"></asp:Label></h2>
                            <small>RPN < 100</small>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card bg-info text-white">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-bar-chart"></i> Ortalama RPN</h5>
                            <h2 class="mb-0"><asp:Label ID="lblAverageRPN" runat="server" Text="0"></asp:Label></h2>
                            <small>Tüm kayıtlar</small>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pareto Analizi -->
            <div class="row mb-4">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0"><i class="bi bi-graph-up"></i> Pareto Analizi (80/20 Kuralı)</h5>
                        </div>
                        <div class="card-body">
                            <div class="chart-container">
                                <asp:Image ID="imgParetoChart" runat="server" CssClass="img-fluid" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header bg-success text-white">
                            <h5 class="mb-0"><i class="bi bi-pie-chart"></i> Risk Dağılımı</h5>
                        </div>
                        <div class="card-body">
                            <div class="chart-container">
                                <asp:Image ID="imgRiskPieChart" runat="server" CssClass="img-fluid" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pareto Tablosu -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header bg-dark text-white">
                            <h5 class="mb-0"><i class="bi bi-list-ol"></i> En Kritik Hata Modları (İlk 10)</h5>
                        </div>
                        <div class="card-body p-0">
                            <asp:GridView ID="gvPareto" runat="server" CssClass="table table-striped table-hover pareto-table mb-0"
                                AutoGenerateColumns="False" GridLines="None">
                                <Columns>
                                    <asp:BoundField DataField="RowNumber" HeaderText="#" ItemStyle-CssClass="text-center" />
                                    <asp:BoundField DataField="ProcessStep" HeaderText="Proses Adımı" />
                                    <asp:BoundField DataField="FailureMode" HeaderText="Hata Modu" />
                                    <asp:BoundField DataField="RPN" HeaderText="RPN" ItemStyle-CssClass="text-center fw-bold" />
                                    <asp:BoundField DataField="Severity" HeaderText="Şiddet" ItemStyle-CssClass="text-center" />
                                    <asp:BoundField DataField="Occurrence" HeaderText="Oluşma" ItemStyle-CssClass="text-center" />
                                    <asp:BoundField DataField="Detection" HeaderText="Tespit" ItemStyle-CssClass="text-center" />
                                    <asp:BoundField DataField="CumulativePercentage" HeaderText="Kümülatif %" 
                                        DataFormatString="{0:F1}" ItemStyle-CssClass="text-center" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Trend Analizi -->
            <div class="row">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header bg-secondary text-white">
                            <h5 class="mb-0"><i class="bi bi-activity"></i> Aylık Risk Trendi</h5>
                        </div>
                        <div class="card-body">
                            <div class="chart-container">
                                <asp:Image ID="imgTrendChart" runat="server" CssClass="img-fluid" />
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header bg-info text-white">
                            <h5 class="mb-0"><i class="bi bi-people"></i> Sorumlu Kişi Dağılımı</h5>
                        </div>
                        <div class="card-body">
                            <asp:GridView ID="gvResponsiblePerson" runat="server" 
                                CssClass="table table-sm table-bordered" AutoGenerateColumns="False">
                                <Columns>
                                    <asp:BoundField DataField="ResponsiblePerson" HeaderText="Sorumlu Kişi" />
                                    <asp:BoundField DataField="AssignedCount" HeaderText="Toplam" ItemStyle-CssClass="text-center" />
                                    <asp:BoundField DataField="OpenCount" HeaderText="Açık" ItemStyle-CssClass="text-center text-danger" />
                                    <asp:BoundField DataField="InProgressCount" HeaderText="Devam" ItemStyle-CssClass="text-center text-warning" />
                                    <asp:BoundField DataField="ClosedCount" HeaderText="Kapalı" ItemStyle-CssClass="text-center text-success" />
                                    <asp:BoundField DataField="AverageRPN" HeaderText="Ort. RPN" DataFormatString="{0:F0}" ItemStyle-CssClass="text-center" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
