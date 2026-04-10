import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/models.dart';

const String _baseUrl = 'http://127.0.0.1:8000';

class ApiService {
  static Future<List<Report>> getReports() async {
    final res = await http.get(Uri.parse('$_baseUrl/api/reports'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((j) => Report.fromJson(j)).toList();
    }
    throw Exception('Failed to load reports');
  }

  static Future<UserStats> getUserStats() async {
    final res = await http.get(Uri.parse('$_baseUrl/api/user/stats'));
    if (res.statusCode == 200) {
      return UserStats.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to load user stats');
  }

  static Future<List<LeaderboardEntry>> getLeaderboard() async {
    final res = await http.get(Uri.parse('$_baseUrl/api/leaderboard'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((j) => LeaderboardEntry.fromJson(j)).toList();
    }
    throw Exception('Failed to load leaderboard');
  }

  static Future<Report> createReport({
    required double lat,
    required double lng,
    required String description,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/reports'),
    );
    request.fields['lat'] = lat.toString();
    request.fields['lng'] = lng.toString();
    request.fields['description'] = description;
    request.files.add(
      http.MultipartFile.fromBytes('file', imageBytes, filename: filename),
    );
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200) {
      return Report.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create report: ${res.body}');
  }

  static Future<void> claimReport(int id) async {
    final res = await http.put(Uri.parse('$_baseUrl/api/reports/$id/claim'));
    if (res.statusCode != 200) throw Exception('Failed to claim');
  }

  static Future<void> completeReport(
      int id, Uint8List? afterImageBytes, String? filename) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/reports/$id/complete'),
    );
    if (afterImageBytes != null && filename != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', afterImageBytes,
            filename: filename),
      );
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) throw Exception('Failed to complete: ${res.body}');
  }
}
