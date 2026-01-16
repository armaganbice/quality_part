# PAYE_UA Flutter Application

This Flutter application provides a mobile interface to interact with the PAYE_UA database, specifically designed to work with the stored procedures for managing template request details and alarms.

## Features

- View template request details with active alarms
- Close alarms for specific template details
- Refresh data to get the latest information
- Clean and intuitive UI for easy operation

## Stored Procedures Used

The application works with the following stored procedures from the PAYE_UA database:

1. **paye_kalip_istek_detay_alarm_calmayanlar** - Retrieves a list of template details with active alarms (`IsAlarmOff = 0`)
2. **paye_kalip_istek_detay_alarm_kapat** - Updates a specific template detail to turn off the alarm (`IsAlarmOff = 1`)

## Prerequisites

- Flutter SDK installed
- Access to the PAYE_UA database through an API endpoint
- Backend service that exposes the stored procedures via HTTP endpoints

## Setup Instructions

1. Clone this repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure your backend API endpoint in `lib/services/database_service.dart`
4. Run the application:
   ```bash
   flutter run
   ```

## API Configuration

Update the `baseUrl` in `lib/services/database_service.dart` to point to your actual backend service that interfaces with the SQL Server database.

The backend should expose the following endpoints:
- POST `/api/exec/paye_kalip_istek_detay_alarm_calmayanlar` - To execute the first stored procedure
- POST `/api/exec/paye_kalip_istek_detay_alarm_kapat` - To execute the second stored procedure with an ID parameter

## Architecture

- **Models**: Contains data models like `TemplateDetail`
- **Services**: Contains API communication logic in `DatabaseService`
- **Providers**: Contains state management logic in `DatabaseProvider`
- **Screens**: Contains UI components starting with `HomeScreen`

## Usage

1. The home screen displays a list of template details with active alarms
2. Each item shows key information: Template Code, Stock Code, Machine Code, Plate Code, and Registration Date
3. Click "Close Alarm" button to turn off the alarm for a specific template detail
4. Use the "Refresh Data" button to reload the list

## Notes

- This application assumes you have a backend service that exposes the SQL Server stored procedures via REST API
- The current implementation includes mock data for demonstration purposes
- For production use, ensure proper authentication and security measures are in place

## Stored Procedure Documentation

### paye_kalip_istek_detay_alarm_calmayanlar
```sql
-- Retrieves all template request details where alarm is active (IsAlarmOff = 0)
SELECT [Id], [KalipKodu], [StokKodu], [TezgahKodu], [LevhaKodu], [KayitTarihi], [IsAlarmOff]
FROM paye_kalip_istek_detay
WHERE IsAlarmOff = 0
```

### paye_kalip_istek_detay_alarm_kapat (@Id int)
```sql
-- Sets IsAlarmOff to 1 for the specified template detail ID
UPDATE paye_kalip_istek_detay
SET IsAlarmOff = 1
WHERE Id = @Id
```
