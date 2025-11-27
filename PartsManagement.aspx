<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PartsManagement.aspx.cs" Inherits="TechnicalDrawingApp.PartsManagement" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Üretilen Parçaların Değerleri</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        .measurement-point {
            position: absolute;
            width: 12px;
            height: 12px;
            background-color: red;
            border-radius: 50%;
            transform: translate(-50%, -50%);
            cursor: pointer;
        }
        
        .measurement-info {
            position: absolute;
            background-color: rgba(255, 255, 255, 0.9);
            border: 1px solid #ccc;
            border-radius: 4px;
            padding: 8px;
            max-width: 200px;
            z-index: 1000;
            display: none;
        }
        
        .part-card {
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        
        .part-header {
            background-color: #f8f9fa;
            padding: 10px;
            border-bottom: 1px solid #ddd;
            border-radius: 5px 5px 0 0;
            cursor: pointer;
        }
        
        .part-content {
            padding: 15px;
        }
        
        .measurement-item {
            padding: 5px 0;
            border-bottom: 1px solid #eee;
        }
        
        .measurement-item:last-child {
            border-bottom: none;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-sm navbar-toggleable-sm navbar-light bg-light border-bottom mb-3">
        <div class="container-fluid">
            <a class="navbar-brand" href="Default.aspx">Teknik Ã‡izim Sistemi</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarSupportedContent"
                    aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="navbar-collapse collapse d-sm-inline-flex justify-content-between" id="navbarNav">
                <ul class="navbar-nav flex-grow-1">
                    <li class="nav-item">
                        <a class="nav-link text-dark" href="Default.aspx">Ana Sayfa</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-dark" href="PartsManagement.aspx">Ãœretilen ParÃ§alar</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <h2 class="my-4">Üretilen Parçaların Değerleri</h2>
            
            <!-- Tabs for navigation -->
            <ul class="nav nav-tabs mb-4" id="myTab" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="list-tab" data-bs-toggle="tab" data-bs-target="#list" type="button" role="tab">Parça Listesi</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="add-tab" data-bs-toggle="tab" data-bs-target="#add" type="button" role="tab">Yeni Parça Ekle</button>
                </li>
            </ul>
            
            <div class="tab-content" id="myTabContent">
                <!-- List Tab -->
                <div class="tab-pane fade show active" id="list" role="tabpanel">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="card">
                                <div class="card-header">
                                    <h5>Parça Kayıtları</h5>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label for="searchPart" class="form-label">Stok Kodu ile Ara:</label>
                                        <div class="input-group">
                                            <input type="text" class="form-control" id="searchPart" placeholder="Stok Kodu girin...">
                                            <button class="btn btn-outline-secondary" type="button" onclick="searchParts()">Ara</button>
                                        </div>
                                    </div>
                                    
                                    <div id="partsList">
                                        <!-- Parts will be loaded here dynamically -->
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Add/Edit Tab -->
                <div class="tab-pane fade" id="add" role="tabpanel">
                    <div class="row">
                        <div class="col-md-8">
                            <div class="card">
                                <div class="card-header">
                                    <h5>Teknik Resim</h5>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label for="stockCodeInput" class="form-label">Stok Kodu:</label>
                                        <input type="text" class="form-control" id="stockCodeInput" placeholder="Stok kodunu girin">
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="drawingImage" class="form-label">Teknik Resim Yükle:</label>
                                        <input type="file" class="form-control" id="drawingImage" accept="image/*" />
                                    </div>
                                    
                                    <div class="mb-3">
                                        <img id="imagePreview" src="" alt="Teknik Resim Önizlemesi" style="max-width: 100%; display: none;" />
                                    </div>
                                    
                                    <div id="imageContainer" style="position: relative; display: none;">
                                        <img id="technicalDrawing" style="max-width: 100%;" />
                                        <div id="measurementPoints"></div>
                                        <div id="measurementInfo" class="measurement-info"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-4">
                            <div class="card">
                                <div class="card-header">
                                    <h5>Ölçüm Noktaları</h5>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <button type="button" class="btn btn-primary" onclick="startAddingPoints()">Nokta Ekleme Modu</button>
                                        <button type="button" class="btn btn-secondary" onclick="clearPoints()">Tüm Noktaları Temizle</button>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="measurementValue" class="form-label">Ölçüm Değeri:</label>
                                        <input type="text" class="form-control" id="measurementValue" placeholder="Ölçüm değerini girin">
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="measurementDescription" class="form-label">Açıklama:</label>
                                        <input type="text" class="form-control" id="measurementDescription" placeholder="Açıklama girin">
                                    </div>
                                    
                                    <div class="mb-3">
                                        <button type="button" class="btn btn-success" onclick="savePart()">Parçayı Kaydet</button>
                                    </div>
                                    
                                    <div id="currentMeasurements">
                                        <!-- Current measurements will be listed here -->
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="script.js"></script>
        <script>
            // Initialize the page
            document.addEventListener('DOMContentLoaded', function() {
                loadPartsList();
            });
            
            function loadPartsList() {
                fetch('PartsManagement.aspx/GetAllParts', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest'
                    }
                })
                .then(response => response.json())
                .then(data => {
                    const parts = JSON.parse(data.d);
                    displayPartsList(parts);
                })
                .catch(error => {
                    console.error('Error loading parts:', error);
                });
            }
            
            function displayPartsList(parts) {
                const container = document.getElementById('partsList');
                container.innerHTML = '';
                
                if (parts.length === 0) {
                    container.innerHTML = '<p>Henüz hiç parça kaydı yok.</p>';
                    return;
                }
                
                parts.forEach(part => {
                    const partCard = document.createElement('div');
                    partCard.className = 'part-card';
                    
                    partCard.innerHTML = `
                        <div class="part-header" onclick="togglePartDetails('${part.StockCode}')">
                            <strong>Stok Kodu:</strong> ${part.StockCode} 
                            <span class="float-end">(${part.Measurements.length} ölçüm)</span>
                        </div>
                        <div class="part-content" id="part-${part.StockCode}" style="display: none;">
                            <div class="row">
                                <div class="col-md-6">
                                    <img src="${part.ImageUrl}" alt="Teknik Resim" style="max-width: 100%; border: 1px solid #ddd;" />
                                </div>
                                <div class="col-md-6">
                                    <h6>Ölçüm Noktaları:</h6>
                                    <div class="measurements-list">
                                        ${part.Measurements.map(m => `
                                            <div class="measurement-item">
                                                <strong>Nokta ${m.Id}:</strong> ${m.Value} - ${m.Description}
                                            </div>
                                        `).join('')}
                                    </div>
                                    <div class="mt-3">
                                        <button class="btn btn-sm btn-primary" onclick="loadPartForEditing('${part.StockCode}')">Düzenle</button>
                                        <button class="btn btn-sm btn-danger" onclick="deletePart('${part.StockCode}')">Sil</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                    
                    container.appendChild(partCard);
                });
            }
            
            function togglePartDetails(stockCode) {
                const content = document.getElementById(`part-${stockCode}`);
                if (content.style.display === 'none') {
                    content.style.display = 'block';
                } else {
                    content.style.display = 'none';
                }
            }
            
            function searchParts() {
                const searchTerm = document.getElementById('searchPart').value;
                
                fetch('PartsManagement.aspx/SearchParts', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: JSON.stringify({ searchTerm: searchTerm })
                })
                .then(response => response.json())
                .then(data => {
                    const parts = JSON.parse(data.d);
                    displayPartsList(parts);
                })
                .catch(error => {
                    console.error('Error searching parts:', error);
                });
            }
            
            function loadPartForEditing(stockCode) {
                // Switch to the add/edit tab
                const addTab = document.getElementById('add-tab');
                addTab.click();
                
                // Load the part data
                fetch('PartsManagement.aspx/GetPartByStockCode', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: JSON.stringify({ stockCode: stockCode })
                })
                .then(response => response.json())
                .then(data => {
                    const part = JSON.parse(data.d);
                    if (part) {
                        document.getElementById('stockCodeInput').value = part.StockCode;
                        document.getElementById('imagePreview').src = part.ImageUrl;
                        document.getElementById('imagePreview').style.display = 'block';
                        document.getElementById('technicalDrawing').src = part.ImageUrl;
                        document.getElementById('imageContainer').style.display = 'block';
                        
                        // Clear existing points
                        clearPoints();
                        
                        // Add the saved measurements as points
                        part.Measurements.forEach(measurement => {
                            addPointToImage(measurement.X, measurement.Y, measurement.Value, measurement.Description, measurement.Id);
                        });
                    }
                })
                .catch(error => {
                    console.error('Error loading part:', error);
                });
            }
            
            function deletePart(stockCode) {
                if (confirm('Bu parçayı ve tüm ölçüm noktalarını silmek istediğinize emin misiniz?')) {
                    fetch('PartsManagement.aspx/DeletePart', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        body: JSON.stringify({ stockCode: stockCode })
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.d) {
                            alert('Parça başarıyla silindi.');
                            loadPartsList();
                        } else {
                            alert('Parça silinirken bir hata oluştu.');
                        }
                    })
                    .catch(error => {
                        console.error('Error deleting part:', error);
                        alert('Parça silinirken bir hata oluştu.');
                    });
                }
            }
            
            function savePart() {
                const stockCode = document.getElementById('stockCodeInput').value;
                if (!stockCode) {
                    alert('Lütfen bir stok kodu girin.');
                    return;
                }
                
                const imageUrl = document.getElementById('technicalDrawing').src;
                const measurements = getCurrentMeasurements();
                
                if (measurements.length === 0) {
                    alert('Lütfen en az bir ölçüm noktası ekleyin.');
                    return;
                }
                
                const partData = {
                    StockCode: stockCode,
                    ImageUrl: imageUrl,
                    Measurements: measurements
                };
                
                fetch('PartsManagement.aspx/SavePart', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: JSON.stringify(partData)
                })
                .then(response => response.json())
                .then(data => {
                    if (data.d) {
                        alert('Parça başarıyla kaydedildi.');
                        document.getElementById('stockCodeInput').value = '';
                        document.getElementById('imagePreview').src = '';
                        document.getElementById('imagePreview').style.display = 'none';
                        document.getElementById('technicalDrawing').src = '';
                        document.getElementById('imageContainer').style.display = 'none';
                        clearPoints();
                        loadPartsList(); // Refresh the list
                        
                        // Switch back to list tab
                        document.getElementById('list-tab').click();
                    } else {
                        alert('Parça kaydedilirken bir hata oluştu.');
                    }
                })
                .catch(error => {
                    console.error('Error saving part:', error);
                    alert('Parça kaydedilirken bir hata oluştu.');
                });
            }
            
            // Update the savePart function to use the global measurements array
            function getCurrentMeasurements() {
                return measurements.map(m => ({
                    Id: m.id,
                    X: m.x,
                    Y: m.y,
                    Value: m.value,
                    Description: m.description
                }));
            }
        </script>
    </form>
</body>
</html>