import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/template_detail.dart';

class DatabaseProvider with ChangeNotifier {
  List<TemplateDetail> _alarmDetails = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Replace with your actual API endpoint
  static const String _baseUrl = 'http://your-api-endpoint.com/api';

  List<TemplateDetail> get alarmDetails => _alarmDetails;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchAlarmDetails() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // This is a mock implementation since we don't have actual API endpoints
      // In real implementation, you would call your database through an API
      final response = await http.post(
        Uri.parse('$_baseUrl/exec/paye_kalip_istek_detay_alarm_calmayanlar'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _alarmDetails = data.map((json) => TemplateDetail.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load data: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> closeAlarm(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Mock implementation for closing alarm
      final response = await http.post(
        Uri.parse('$_baseUrl/exec/paye_kalip_istek_detay_alarm_kapat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      );

      if (response.statusCode == 200) {
        // Update local list
        _alarmDetails.removeWhere((detail) => detail.id == id);
        return true;
      } else {
        _errorMessage = 'Failed to close alarm: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mock data for demonstration
  void loadMockData() {
    _alarmDetails = [
      TemplateDetail(
        id: 1,
        kalipKodu: 'K001',
        stokKodu: 'S001',
        tezgahKodu: 'T001',
        levhaKodu: 'L001',
        kayitTarihi: DateTime.now(),
        isAlarmOff: false,
      ),
      TemplateDetail(
        id: 2,
        kalipKodu: 'K002',
        stokKodu: 'S002',
        tezgahKodu: 'T002',
        levhaKodu: 'L002',
        kayitTarihi: DateTime.now().subtract(Duration(hours: 2)),
        isAlarmOff: false,
      ),
    ];
    notifyListeners();
  }
}