import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_exception.dart';

enum HttpMethod { get, post, put, delete }

class DioClient {
  final Dio dio;
  String? _authToken;

  DioClient({required this.dio}) {
    _loadTokenFromStorage();
  }

  Future<void> _loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('authToken');
  }

  Future<void> _saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    _authToken = null;
  }

  void setAuthToken(String token) {
    _authToken = token;
    _saveTokenToStorage(token);
  }

  Options _requestOptions() {
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': _authToken != null ? 'Bearer $_authToken' : '',
      },
    );
  }

  void _logRequest(String method, String path, [Map<String, dynamic>? body]) {
    debugPrint("===========API $method REQUEST===========");
    debugPrint("REQUEST URL: ${dio.options.baseUrl + path}");
    debugPrint("REQUEST BODY: ${body?.toString() ?? 'No body'}");
  }

  void _logResponse(Response response) {
    debugPrint("===========API RESPONSE===========");
    debugPrint("RESPONSE STATUS CODE: ${response.statusCode}");
    debugPrint("RESPONSE DATA: ${response.data.toString()}");
  }

  void _handleError(DioException e) {
    if (e.response != null) {
      debugPrint(e.response!.data.toString());
      debugPrint(e.response!.headers.toString());
      debugPrint(e.response!.requestOptions.toString());
      throw ApiException(
        message: e.response!.statusMessage ?? 'Erreur inconnue',
      );
    } else {
      debugPrint(e.requestOptions.toString());
      debugPrint(e.message);
      debugPrint(e.type.toString());
      throw ApiException(message: e.message);
    }
  }

  Future<Response> makeRequest({
    required HttpMethod method,
    required String path,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Log the request
      _logRequest(method.toString().toUpperCase(), path, data);

      Response response;
      switch (method) {
        case HttpMethod.get:
          response = await dio.get(path, options: _requestOptions());
          break;
        case HttpMethod.post:
          response = await dio.post(path, data: data, options: _requestOptions());
          break;
        case HttpMethod.put:
          response = await dio.put(path, data: data, options: _requestOptions());
          break;
        case HttpMethod.delete:
          response = await dio.delete(path, options: _requestOptions());
          break;
      }

      // Log the response
      _logResponse(response);

      // Gestion du token après connexion
      if (method == HttpMethod.post && path.contains('/login')) {
        final token = response.data["token"];
        if (token != null) {
          setAuthToken(token);
        }
      }

      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}
