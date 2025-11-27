// Technical Drawing Measurement System
document.addEventListener('DOMContentLoaded', function() {
    // DOM Elements
    const fileUpload = document.getElementById('fileUpload');
    const drawingCanvas = document.getElementById('drawingCanvas');
    const drawingContainer = document.getElementById('drawingContainer');
    const placeholder = document.getElementById('placeholder');
    const addPointBtn = document.getElementById('addPointBtn');
    const saveMeasurementsBtn = document.getElementById('saveMeasurementsBtn');
    const clearPointsBtn = document.getElementById('clearPointsBtn');
    const loadMeasurementsBtn = document.getElementById('loadMeasurementsBtn');
    const updateMeasurementsBtn = document.getElementById('updateMeasurementsBtn');
    const stockCodeInput = document.getElementById('stockCode');
    const pointValueInput = document.getElementById('pointValue');
    const pointDescriptionInput = document.getElementById('pointDescription');
    const measurementsList = document.getElementById('measurementsList');
    
    // Application state
    let measurementPoints = [];
    let isAddingPointMode = false;
    let currentPointId = 1;
    let currentStockCode = '';
    
    // Event Listeners
    fileUpload.addEventListener('change', handleFileUpload);
    addPointBtn.addEventListener('click', toggleAddPointMode);
    saveMeasurementsBtn.addEventListener('click', saveMeasurements);
    clearPointsBtn.addEventListener('click', clearAllPoints);
    loadMeasurementsBtn.addEventListener('click', loadMeasurements);
    updateMeasurementsBtn.addEventListener('click', updateMeasurements);
    drawingCanvas.addEventListener('click', handleCanvasClick);
    
    // Handle file upload
    function handleFileUpload(event) {
        const file = event.target.files[0];
        if (file && file.type.match('image.*')) {
            const reader = new FileReader();
            
            reader.onload = function(e) {
                drawingCanvas.src = e.target.result;
                drawingCanvas.style.display = 'block';
                placeholder.style.display = 'none';
                
                // Enable buttons after image is loaded
                addPointBtn.disabled = false;
                saveMeasurementsBtn.disabled = false;
                clearPointsBtn.disabled = false;
                
                // Reset points when new image is loaded
                clearAllPoints();
            };
            
            reader.readAsDataURL(file);
        }
    }
    
    // Toggle add point mode
    function toggleAddPointMode() {
        isAddingPointMode = !isAddingPointMode;
        
        if (isAddingPointMode) {
            addPointBtn.textContent = 'Cancel Add Point';
            addPointBtn.classList.add('btn-danger');
            addPointBtn.classList.remove('btn-primary');
            alert('Click on the drawing to add a measurement point');
        } else {
            addPointBtn.textContent = 'Add Measurement Point';
            addPointBtn.classList.add('btn-primary');
            addPointBtn.classList.remove('btn-danger');
        }
    }
    
    // Handle canvas click to add measurement point
    function handleCanvasClick(event) {
        if (!isAddingPointMode) return;
        
        const rect = drawingCanvas.getBoundingClientRect();
        const x = event.clientX - rect.left;
        const y = event.clientY - rect.top;
        
        // Create measurement point element
        const point = document.createElement('div');
        point.className = 'measurement-point';
        point.style.left = `${x}px`;
        point.style.top = `${y}px`;
        point.dataset.id = currentPointId;
        
        // Add click event to edit the point
        point.addEventListener('click', function(e) {
            e.stopPropagation();
            editPoint(currentPointId);
        });
        
        drawingContainer.appendChild(point);
        
        // Create point label
        const label = document.createElement('div');
        label.className = 'point-label';
        label.style.left = `${x}px`;
        label.style.top = `${y}px`;
        label.textContent = `Point ${currentPointId}`;
        label.dataset.id = currentPointId;
        
        drawingContainer.appendChild(label);
        
        // Add to our internal list
        measurementPoints.push({
            id: currentPointId,
            x: x,
            y: y,
            value: '',
            description: ''
        });
        
        // Add to measurements list
        addPointToList(currentPointId, x, y, '', '');
        
        currentPointId++;
        
        // Exit point adding mode after one point
        isAddingPointMode = false;
        addPointBtn.textContent = 'Add Measurement Point';
        addPointBtn.classList.add('btn-primary');
        addPointBtn.classList.remove('btn-danger');
    }
    
    // Add point to measurements list
    function addPointToList(id, x, y, value, description) {
        const item = document.createElement('div');
        item.className = 'measurement-item';
        item.dataset.id = id;
        
        item.innerHTML = `
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <strong>Point ${id}</strong><br>
                    <small>Position: (${Math.round(x)}, ${Math.round(y)})</small><br>
                    <small>Value: ${value || 'Not set'}</small><br>
                    <small>Desc: ${description || 'No description'}</small>
                </div>
                <button type="button" class="btn btn-sm btn-outline-primary edit-point-btn" data-id="${id}">Edit</button>
            </div>
        `;
        
        // Add edit button event
        const editBtn = item.querySelector('.edit-point-btn');
        editBtn.addEventListener('click', function() {
            editPoint(id);
        });
        
        measurementsList.appendChild(item);
        
        // Update if no measurements message exists
        const noMeasurements = measurementsList.querySelector('.text-muted');
        if (noMeasurements) {
            noMeasurements.remove();
        }
    }
    
    // Edit point function
    function editPoint(id) {
        const point = measurementPoints.find(p => p.id === id);
        if (!point) return;
        
        // Populate form with current values
        pointValueInput.value = point.value || '';
        pointDescriptionInput.value = point.description || '';
        
        // Show a modal or use prompt for editing
        const newValue = prompt('Enter measurement value for Point ' + id + ':', point.value);
        if (newValue !== null) {
            point.value = newValue;
            
            // Update description if needed
            const newDescription = prompt('Enter description for Point ' + id + ':', point.description);
            if (newDescription !== null) {
                point.description = newDescription;
            }
            
            // Update the list item
            updatePointInList(id, point.value, point.description);
        }
    }
    
    // Update point in the measurements list
    function updatePointInList(id, value, description) {
        const listItem = measurementsList.querySelector(`[data-id="${id}"]`);
        if (listItem) {
            const strongElement = listItem.querySelector('strong');
            const valueElement = listItem.querySelector('small:nth-child(3)');
            const descElement = listItem.querySelector('small:nth-child(4)');
            
            if (valueElement) {
                valueElement.innerHTML = `Value: ${value || 'Not set'}`;
            }
            if (descElement) {
                descElement.innerHTML = `Desc: ${description || 'No description'}`;
            }
        }
        
        // Also update the label on the drawing
        const label = drawingContainer.querySelector(`.point-label[data-id="${id}"]`);
        if (label) {
            label.textContent = `Point ${id}: ${value || ''}`;
        }
    }
    
    // Save measurements to server
    function saveMeasurements() {
        if (!currentStockCode) {
            alert('Please enter a stock code before saving measurements');
            return;
        }
        
        if (measurementPoints.length === 0) {
            alert('No measurement points to save');
            return;
        }
        
        // Prepare data to send to server
        const measurementsData = {
            stockCode: currentStockCode,
            points: measurementPoints
        };
        
        // In a real application, you would send this to the server
        console.log('Saving measurements:', measurementsData);
        
        // For this example, we'll just show a success message
        alert(`Measurements saved for stock code: ${currentStockCode}`);
    }
    
    // Load measurements from server
    function loadMeasurements() {
        const stockCode = stockCodeInput.value.trim();
        if (!stockCode) {
            alert('Please enter a stock code to load measurements');
            return;
        }
        
        // In a real application, you would fetch data from the server
        // For this example, we'll simulate loading from a database
        currentStockCode = stockCode;
        
        // Clear current points
        clearAllPoints();
        
        // Simulate loading data (in a real app, this would come from server)
        const samplePoints = [
            { id: 1, x: 100, y: 150, value: '10.5mm', description: 'Diameter measurement' },
            { id: 2, x: 200, y: 250, value: '25.3mm', description: 'Length measurement' },
            { id: 3, x: 300, y: 100, value: '8.2mm', description: 'Width measurement' }
        ];
        
        // Add loaded points to the drawing
        samplePoints.forEach(point => {
            // Create measurement point element
            const pointEl = document.createElement('div');
            pointEl.className = 'measurement-point';
            pointEl.style.left = `${point.x}px`;
            pointEl.style.top = `${point.y}px`;
            pointEl.dataset.id = point.id;
            
            // Add click event to edit the point
            pointEl.addEventListener('click', function(e) {
                e.stopPropagation();
                editPoint(point.id);
            });
            
            drawingContainer.appendChild(pointEl);
            
            // Create point label
            const label = document.createElement('div');
            label.className = 'point-label';
            label.style.left = `${point.x}px`;
            label.style.top = `${point.y}px`;
            label.textContent = `Point ${point.id}: ${point.value}`;
            label.dataset.id = point.id;
            
            drawingContainer.appendChild(label);
            
            // Add to our internal list
            measurementPoints.push(point);
            
            // Add to measurements list
            addPointToList(point.id, point.x, point.y, point.value, point.description);
        });
        
        if (samplePoints.length > 0) {
            currentPointId = Math.max(...samplePoints.map(p => p.id)) + 1;
        }
        
        alert(`Measurements loaded for stock code: ${stockCode}`);
    }
    
    // Update measurements (similar to save but for existing data)
    function updateMeasurements() {
        if (!currentStockCode) {
            alert('No current stock code. Load measurements first or enter a stock code.');
            return;
        }
        
        saveMeasurements();
    }
    
    // Clear all points
    function clearAllPoints() {
        // Remove all measurement points from the drawing
        const points = drawingContainer.querySelectorAll('.measurement-point, .point-label');
        points.forEach(point => point.remove());
        
        // Clear the measurements list
        measurementsList.innerHTML = '<div class="text-muted">No measurements added yet</div>';
        
        // Reset internal state
        measurementPoints = [];
        currentPointId = 1;
    }
    
    // Initialize the application
    function initApp() {
        // Set up any initial state
        console.log('Technical Drawing Measurement System initialized');
    }
    
    // Initialize the application
    initApp();
});