import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'http://192.168.1.6:8000/api'; // Update with your actual API URL

  // REGISTER USER
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body); // Success response
      } else {
        return {'error': 'Registration failed. Please try again.'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  // LOGIN USER
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        // Save the token, user name, and user ID after login
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', data['token']);
        prefs.setString('user_name', data['user']['name']);
        prefs.setInt('user_id', data['user']['id']); // Save user ID here

        return data; // Return token and user info
      } else {
        return {'error': 'Login failed. Please check your credentials.'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  // GET PROFILE
  Future<Map<String, dynamic>> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return profile data
      } else {
        return {'error': 'Failed to fetch profile.'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  // UPDATE PROFILE
  Future<Map<String, dynamic>> updateProfile(String name, String email) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      final response = await http.put(
        Uri.parse('$baseUrl/update-profile'),
        headers: {'Authorization': 'Bearer $token'},
        body: {'name': name, 'email': email},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return updated profile data
      } else {
        return {'error': 'Failed to update profile.'};
      }
    } catch (e) {
      return {'error': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> sendLocationToApi(
      double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/location'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        }),
      );

      if (response.statusCode == 200) {
        print('Location sent successfully: ${response.body}');
        return {'success': true, 'message': 'Location successfully saved!'};
      } else {
        return {
          'error': 'Failed to send location but success saved in database'
        };
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Fetch list of locations from the API
  Future<List<Map<String, dynamic>>> fetchLocations() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        return []; // Return empty list if no token is found (unauthenticated user)
      }

      final response = await http.get(
        Uri.parse('$baseUrl/locations'),
        headers: {
          'Authorization': 'Bearer $token', // Send token in the header
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(
            data); // Return list of locations
      } else {
        return []; // Return empty list if request fails
      }
    } catch (e) {
      return []; // Return empty list in case of an exception
    }
  }
}
