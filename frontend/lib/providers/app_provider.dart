import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppNotification {
  final String message;
  final String type; // success, error, points, ai
  AppNotification({required this.message, required this.type});
}

class AppProvider extends ChangeNotifier {
  List<Report> _reports = [];
  UserStats? _userStats;
  List<LeaderboardEntry> _leaderboard = [];
  AppNotification? _notification;
  bool _isLoading = false;
  WebSocketChannel? _wsChannel;

  List<Report> get reports => _reports;
  UserStats? get userStats => _userStats;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  AppNotification? get notification => _notification;
  bool get isLoading => _isLoading;

  void showNotification(String message, String type) {
    _notification = AppNotification(message: message, type: type);
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _notification = null;
      notifyListeners();
    });
  }

  void connectWebSocket() {
    if (_wsChannel != null) return;
    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:8000/api/ws'));
      _wsChannel!.stream.listen((message) {
        final data = jsonDecode(message);
        if (data['event'] == 'report_new') {
          final newReport = Report.fromJson(data['data']);
          _reports = [..._reports, newReport];
          notifyListeners();
        } else if (data['event'] == 'report_updated') {
          final updatedReport = Report.fromJson(data['data']);
          _reports = _reports.map((r) => r.id == updatedReport.id ? updatedReport : r).toList();
          notifyListeners();
        } else if (data['event'] == 'leaderboard_updated') {
          fetchAll(); // Refresh leaderboard and stats
        }
      }, onError: (e) {
        debugPrint('WebSocket Error: $e');
      });
    } catch (e) {
      debugPrint('WebSocket Connection Failed: $e');
    }
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        ApiService.getReports(),
        ApiService.getUserStats(),
        ApiService.getLeaderboard(),
      ]);
      _reports = results[0] as List<Report>;
      _userStats = results[1] as UserStats;
      _leaderboard = results[2] as List<LeaderboardEntry>;
    } catch (e) {
      debugPrint('Fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReport({
    required double lat,
    required double lng,
    required String description,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    try {
      final newReport = await ApiService.createReport(
        lat: lat,
        lng: lng,
        description: description,
        imageBytes: imageBytes,
        filename: filename,
      );
      _reports = [..._reports, newReport];
      notifyListeners();
      showNotification('Report submitted! AI analyzed it 🤖', 'ai');
      await fetchAll();
    } catch (e) {
      showNotification('Failed to submit report', 'error');
      rethrow;
    }
  }

  Future<void> claimReport(int id) async {
    try {
      await ApiService.claimReport(id);
      _reports = _reports.map((r) {
        return r.id == id ? r.copyWith(status: 'In Progress') : r;
      }).toList();
      if (_userStats != null) {
        _userStats = _userStats!.copyWith(points: _userStats!.points + 10);
      }
      notifyListeners();
      showNotification('+10 Points! Task claimed ⚡', 'points');
      // No need to fetchAll(), websocket triggers updates.
    } catch (e) {
      showNotification('Failed to claim task', 'error');
    }
  }

  Future<void> completeReport(int id, Uint8List? afterImageBytes, String? filename) async {
    try {
      // Find the report to get severity for optimistic calculation
      final report = _reports.where((r) => r.id == id).firstOrNull;
      if (report != null && _userStats != null) {
        int pts = 10;
        if (report.severity == 'High') pts = 50;
        else if (report.severity == 'Medium') pts = 25;

        _userStats = _userStats!.copyWith(
          points: _userStats!.points + pts,
          totalCleanups: _userStats!.totalCleanups + 1,
          trustScore: _userStats!.trustScore + 2,
        );
      }

      await ApiService.completeReport(id, afterImageBytes, filename);
      
      // Optimistic status update
      _reports = _reports.map((r) {
        return r.id == id ? r.copyWith(status: 'Cleaned') : r;
      }).toList();
      
      notifyListeners();
      showNotification('Proof submitted! Analyzing... 🎉', 'ai');
    } catch (e) {
      showNotification('Failed to complete task', 'error');
    }
  }
}
