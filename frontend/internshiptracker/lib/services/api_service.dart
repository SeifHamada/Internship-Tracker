import 'dart:convert';
import 'dart:async'; // for TimeoutException
import 'dart:io';    // for SocketException
import 'package:http/http.dart' as http;
import '../models/application.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000';

  // Generic GET helper
  Future<http.Response> _get(String url) async {
    try {
      return await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw Exception('Request timed out. Backend might be offline.');
    } on SocketException {
      throw Exception('No internet or cannot reach server.');
    }
  }

  // Generic POST helper
  Future<http.Response> _post(String url, Map<String, dynamic> data) async {
    try {
      return await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw Exception('Request timed out. Backend might be offline.');
    } on SocketException {
      throw Exception('No internet or cannot reach server.');
    }
  }

  // Generic PUT helper
  Future<http.Response> _put(String url, Map<String, dynamic> data) async {
    try {
      return await http
          .put(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw Exception('Request timed out.');
    } on SocketException {
      throw Exception('No internet or cannot reach server.');
    }
  }

  // Generic DELETE helper
  Future<http.Response> _delete(String url) async {
    try {
      return await http
          .delete(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      throw Exception('Request timed out.');
    } on SocketException {
      throw Exception('No internet or cannot reach server.');
    }
  }

  // GET all
  Future<List<Application>> getApplications() async {
    final response = await _get('$baseUrl/applications');

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Application.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load applications (${response.statusCode})');
    }
  }

  // GET one
  Future<Application> getApplication(int id) async {
    final response = await _get('$baseUrl/applications/$id');

    if (response.statusCode == 200) {
      return Application.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Application not found (${response.statusCode})');
    }
  }

  // POST
  Future<Application> createApplication(Map<String, dynamic> data) async {
    final response = await _post('$baseUrl/applications', data);

    if (response.statusCode == 201) {
      return Application.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to create application (${response.statusCode}): ${response.body}',
      );
    }
  }

  // PUT
  Future<Application> updateApplication(
      int id, Map<String, dynamic> data) async {
    final response = await _put('$baseUrl/applications/$id', data);

    if (response.statusCode == 200) {
      return Application.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to update application (${response.statusCode})',
      );
    }
  }

  // DELETE
  Future<bool> deleteApplication(int id) async {
    final response = await _delete('$baseUrl/applications/$id');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to delete application (${response.statusCode})',
      );
    }
  }
}