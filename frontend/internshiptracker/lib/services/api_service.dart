import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/application.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000';

  // GET /applications
  // Fetches all applications from the database
  // Returns a list of Application objects
  Future<List<Application>> getApplications() async {
    final response = await http.get(Uri.parse('$baseUrl/applications'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Application.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load applications');
    }
  }

  // GET /applications/{id}
  // Fetches a single application by its ID
  // Returns one Application object
  Future<Application> getApplication(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/applications/$id'));
    if (response.statusCode == 200) {
      return Application.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Application not found');
    }
  }

  // POST /applications
  // Creates a new application in the database
  // Receives a map of application data, returns the created Application object
  Future<Application> createApplication(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/applications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Application.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create application');
    }
  }

  // PUT /applications/{id}
  // Updates an existing application by its ID
  // Only sends the fields that changed - backend handles partial updates
  Future<Application> updateApplication(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/applications/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Application.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update application');
    }
  }

  // DELETE /applications/{id}
  // Deletes an application by its ID
  // Returns true if deletion was successful
  Future<bool> deleteApplication(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/applications/$id'));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete application');
    }
  }
}