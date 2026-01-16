import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load mock data for demonstration
    Provider.of<DatabaseProvider>(context, listen: false).loadMockData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('PAYE_UA Alarm Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Template Request Details with Active Alarms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          
          if (provider.errorMessage.isNotEmpty)
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              color: Colors.red[100],
              child: Text(
                provider.errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ),
          
          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator())
                : provider.alarmDetails.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No active alarms',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          // In a real app, this would fetch fresh data from API
                          provider.loadMockData();
                        },
                        child: ListView.builder(
                          itemCount: provider.alarmDetails.length,
                          itemBuilder: (context, index) {
                            final detail = provider.alarmDetails[index];
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                title: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Template Code: ${detail.kalipKodu}',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text('Stock Code: ${detail.stokKodu}'),
                                          Text('Machine Code: ${detail.tezgahKodu}'),
                                          Text('Plate Code: ${detail.levhaKodu}'),
                                          Text(
                                            'Date: ${detail.kayitTarihi.toString().substring(0, 19)}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        bool success = await provider.closeAlarm(detail.id);
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Alarm closed for ID: ${detail.id}'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed to close alarm'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text('Close Alarm'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
          
          Container(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Fetch fresh data (in mock implementation, just reloads mock data)
                provider.loadMockData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Refresh Data'),
            ),
          ),
        ],
      ),
    );
  }
}