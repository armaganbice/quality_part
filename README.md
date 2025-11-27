# Technical Drawing Measurement System

This is an ASP.NET web application that allows users to upload technical drawings, mark red measurement points, define values, and recall these measurements by stock code.

## Features

- Upload technical drawings (images)
- Mark red measurement points on the drawing
- Define measurement values and descriptions for each point
- Save measurements associated with a stock code
- Load previously saved measurements by stock code
- Edit existing measurement points
- Responsive UI using Bootstrap 5

## How to Use

1. Upload a technical drawing using the file upload control
2. Click "Add Measurement Point" and then click on the drawing to place red measurement points
3. Edit the measurement values and descriptions for each point
4. Enter a stock code and save the measurements
5. Later, enter the same stock code and click "Load Measurements" to retrieve previously saved points

## Files

- `Default.aspx` - Main page with the UI
- `Default.aspx.cs` - Server-side code
- `script.js` - Client-side JavaScript functionality
- `web.config` - Configuration file
- `Global.asax` - Application-level events

## Technologies Used

- ASP.NET (C#)
- JavaScript
- Bootstrap 5
- HTML5 Canvas approach for image interaction

The application simulates database storage using in-memory collections. In a production environment, you would connect this to a real database.
