import 'dart:convert';
import 'dart:io';
import 'package:apiapp/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignupService {
  // API endpoints
  final String signupUrl = '$baseURL/api/auth/register';
  final String loginUrl = '$baseURL/api/auth/login';
  final String addblogUrl = '$baseURL/api/blogs/addblog';
  final String getBlogsUrl = '$baseURL/api/blogs/viewblog';

  // Signup method
  Future<Map<String, dynamic>> signup({
    required BuildContext context,
    required String username,
    required String email,
    required String password,
    required String place,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(signupUrl),
        body: {
          'name': username,
          'email': email,
          'password': password,
          'place': place,
          'phone': phone,
        },
      );

      if (response.statusCode == 201) {
        print(response.body);
        return jsonDecode(response.body);
      } else if (response.statusCode == 500) {
        _showErrorSnackbar(
            context, 'Internal server error. Please try again later.');
        throw Exception('Failed to sign up');
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String errorMessage =
            responseBody['message'] ?? 'Failed to sign up';
        _showErrorSnackbar(context, errorMessage);
        throw Exception('Failed to sign up');
      }
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
      rethrow;
    }
  }

  // Login method
  Future<Map<String, dynamic>> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        body: {
          'email': email,
          'password': password,
        },
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String token = responseBody['token'];
        await _saveToken(token); // Save token to SharedPreferences
        return responseBody;
      } else if (response.statusCode == 500) {
        throw Exception('Internal server error. Please try again later.');
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String errorMessage =
            responseBody['message'] ?? 'Failed to log in';
        throw Exception(errorMessage);
      }
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
      rethrow;
    }
  }

  // Add blog method
  Future<Map<String, dynamic>> addBlog({
    required BuildContext context,
    required String title,
    required String content,
    required String author,
    required String timestamp,
    required File? image,
  }) async {
    try {
      final token = await _getToken(); // Retrieve token from SharedPreferences

      final request = http.MultipartRequest('POST', Uri.parse(addblogUrl))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['title'] = title
        ..fields['content'] = content
        ..fields['author'] = author
        ..fields['timestamp'] = timestamp;

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print(responseBody);
      print(response.statusCode);

      if (response.statusCode == 201) {
        return jsonDecode(responseBody);
      } else if (response.statusCode == 500) {
        throw Exception('Internal server error. Please try again later.');
      } else {
        final Map<String, dynamic> responseBodyMap = jsonDecode(responseBody);
        final String errorMessage =
            responseBodyMap['message'] ?? 'Failed to add blog';
        throw Exception(errorMessage);
      }
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
      rethrow;
    }
  }

  // Get blogs method
  Future<List<dynamic>> getBlogs(BuildContext context) async {
    try {
      final token = await _getToken(); // Retrieve token from SharedPreferences

      print(token);

      final response = await http.get(
        Uri.parse(getBlogsUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else if (response.statusCode == 500) {
        throw Exception('Internal server error. Please try again later.');
      } else if (response.statusCode == 404) {
        throw Exception('Not Found');
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String errorMessage =
            responseBody['message'] ?? 'Failed to fetch blogs';
        throw Exception(errorMessage);
      }
    } catch (e) {
      _showErrorSnackbar(context, e.toString());
      rethrow;
    }
  }

  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
