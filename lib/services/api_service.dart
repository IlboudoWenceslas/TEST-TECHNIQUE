import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../model/event.dart';
import '../model/registration.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  ApiService() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<List<Event>> getEvents({String? search}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final res = await _dio.get('/events', queryParameters: params);
    return (res.data as List).map((e) => Event.fromJson(e)).toList();
  }

  Future<Event> getEvent(int id) async {
    final res = await _dio.get('/events/$id');
    return Event.fromJson(res.data);
  }

  Future<List<Registration>> getRegistrations(int eventId) async {
    final res = await _dio.get('/events/$eventId/registrations');
    return (res.data as List).map((e) => Registration.fromJson(e)).toList();
  }

  Future<Registration> register(int eventId, String firstName, String lastName, String email) async {
    final res = await _dio.post('/events/$eventId/register', data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    });
    return Registration.fromJson(res.data);
  }

  Future<void> deleteRegistration(int id) async {
    await _dio.delete('/registrations/$id');
  }

  Future<String> login(String email, String password) async {
    final res = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    return res.data['access_token'];
  }

  Future<String> register_user(String firstName, String lastName, String email, String password) async {
    final res = await _dio.post('/register', data: {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    });
    return res.data['access_token'];
  }
  Future<void> deleteEvent(int id, String token) async {
    await _dio.delete('/events/$id', options: Options(headers: {'Authorization': 'Bearer $token'}));
  }

  Future<Event> updateEvent(int id, Map<String, dynamic> data, String token) async {
    final res = await _dio.put('/events/$id', data: data, options: Options(headers: {'Authorization': 'Bearer $token'}));
    return Event.fromJson(res.data);
  }
}