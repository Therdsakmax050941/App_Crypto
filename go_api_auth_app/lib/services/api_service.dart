import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  final String _baseUrl = 'http://10.0.2.2:8080'; // ใช้สำหรับ Android Emulator

  Future<String?> _getToken() async {
    final authService = AuthService();
    return await authService.getToken();
  }

  Future<http.Response> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/CreateUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception('Failed to register user');
    }
  }

  Future<http.Response> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final authService = AuthService();
      await authService.saveToken(token);
      return response;
    } else {
      throw Exception('Failed to login user');
    }
  }

  Future<http.Response> getUserData() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/protected'),
      headers: <String, String>{
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to fetch user data');
    }
  }

}

