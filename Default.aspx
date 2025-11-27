<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="TechnicalDrawingApp.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Technical Drawing Measurement System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .drawing-container {
            position: relative;
            margin: 20px auto;
            border: 2px solid #ddd;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        
        #drawingCanvas {
            display: block;
            max-width: 100%;
        }
        
        .measurement-point {
            position: absolute;
            width: 12px;
            height: 12px;
            background-color: red;
            border-radius: 50%;
            transform: translate(-50%, -50%);
            cursor: pointer;
            z-index: 10;
        }
        
        .measurement-point:hover {
            transform: translate(-50%, -50%) scale(1.3);
        }
        
        .point-label {
            position: absolute;
            background-color: red;
            color: white;
            padding: 2px 5px;
            border-radius: 3px;
            font-size: 12px;
            transform: translate(10px, -50%);
            z-index: 11;
        }
        
        .controls-panel {
            margin: 20px 0;
        }
        
        .measurement-list {
            max-height: 300px;
            overflow-y: auto;
            margin-top: 15px;
        }
        
        .measurement-item {
            padding: 8px;
            border-bottom: 1px solid #eee;
        }
        
        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <h2 class="text-center mb-4">Technical Drawing Measurement System</h2>
                </div>
            </div>
            
            <div class="row">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">
                            <h5>Technical Drawing</h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label for="fileUpload" class="form-label">Upload Technical Drawing</label>
                                <input type="file" class="form-control" id="fileUpload" accept="image/*" />
                            </div>
                            
                            <div id="drawingContainer" class="drawing-container text-center">
                                <img id="drawingCanvas" src="" alt="Technical Drawing" style="max-width: 100%; display: none;" />
                                <div id="placeholder" class="text-muted p-5">No image uploaded yet</div>
                            </div>
                            
                            <div class="mt-3">
                                <button type="button" class="btn btn-primary" id="addPointBtn" disabled>Add Measurement Point</button>
                                <button type="button" class="btn btn-success" id="saveMeasurementsBtn" disabled>Save Measurements</button>
                                <button type="button" class="btn btn-info" id="clearPointsBtn" disabled>Clear Points</button>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">
                            <h5>Measurement Management</h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label for="stockCode" class="form-label">Stock Code</label>
                                <input type="text" class="form-control" id="stockCode" placeholder="Enter stock code" />
                            </div>
                            
                            <div class="mb-3">
                                <label for="pointValue" class="form-label">Measurement Value</label>
                                <input type="text" class="form-control" id="pointValue" placeholder="Enter measurement value" />
                            </div>
                            
                            <div class="mb-3">
                                <label for="pointDescription" class="form-label">Description</label>
                                <input type="text" class="form-control" id="pointDescription" placeholder="Enter description" />
                            </div>
                            
                            <div class="d-grid gap-2">
                                <button type="button" class="btn btn-primary" id="loadMeasurementsBtn">Load Measurements</button>
                                <button type="button" class="btn btn-warning" id="updateMeasurementsBtn">Update Measurements</button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="card mt-3">
                        <div class="card-header">
                            <h5>Current Measurements</h5>
                        </div>
                        <div class="card-body">
                            <div id="measurementsList" class="measurement-list">
                                <!-- Measurement points will be listed here -->
                                <div class="text-muted">No measurements added yet</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="script.js"></script>
    </form>
</body>
</html>