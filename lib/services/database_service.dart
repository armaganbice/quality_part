import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  // Base URL should be configured based on your backend API
  static const String baseUrl = 'http://your-server-address.com/api';
  
  // Headers for HTTP requests
  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Executes the stored procedure paye_kalip_istek_detay_alarm_calmayanlar
  /// Returns a list of template details with active alarms
  static Future<List<Map<String, dynamic>>> getAlarmDetails() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/exec/paye_kalip_istek_detay_alarm_calmayanlar'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load alarm details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting alarm details: $e');
    }
  }

  /// Executes the stored procedure paye_kalip_istek_detay_alarm_kapat with the given ID
  /// Turns off the alarm for the specified template detail
  static Future<bool> closeAlarmById(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/exec/paye_kalip_istek_detay_alarm_kapat'),
        headers: headers,
        body: json.encode({'id': id}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to close alarm: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error closing alarm: $e');
    }
  }
  
  /// Test connection to the database
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: headers,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}