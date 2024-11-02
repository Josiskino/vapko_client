import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

import '../utils/api_exception.dart';

class DioClient {
  final Dio dio;
  String? _authToken;

  DioClient({required this.dio}) {
    _loadTokenFromStorage(); 
  }

  void _logRequest(String method, String path, [Map<String, dynamic>? body]) {
    debugPrint("===========API $method REQUEST===========");
    debugPrint("REQUEST URL: ${dio.options.baseUrl + path}");
    if (body != null) {
      debugPrint("REQUEST BODY: ${body.toString()}");
    } else {
      debugPrint("REQUEST BODY: No body");
    }
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

  // Charger le token depuis le stockage local
  Future<void> _loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('authToken');
  }

  // Stocker le token dans le stockage local
  Future<void> _saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  // Supprimer le token du stockage local
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    _authToken = null;
  }

  // Méthode pour définir un token d'authentification
  void setAuthToken(String token) {
    _authToken = token;
    _saveTokenToStorage(token); 
  }

  Options _requestOptions() {
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _authToken != null ? 'Bearer $_authToken' : '',
      },
    );
  }

  Future<Response> getRequest({required String path}) async {
    try {
      _logRequest("GET", path);
      final response = await dio.get(path, options: _requestOptions());
      _logResponse(response);
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> postRequest(
      {required String path, Map<String, dynamic>? data}) async {
    try {
      _logRequest("POST", path, data);
      final response = await dio.post(
        path,
        data: data,
        options: _requestOptions(),
      );
      _logResponse(response);

      // Gestion du token après connexion
      if (path.contains('/login')) { 
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

  Future<Response> putRequest(
      {required String path, Map<String, dynamic>? data}) async {
    try {
      _logRequest("PUT", path, data);
      final response =
          await dio.put(path, data: data, options: _requestOptions());
      _logResponse(response);
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> deleteRequest({required String path}) async {
    try {
      _logRequest("DELETE", path);
      final response = await dio.delete(path, options: _requestOptions());
      _logResponse(response);
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> uploadImage(
      {required String path, required String filePath}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      _logRequest("POST", path);
      final response =
          await dio.post(path, data: formData, options: _requestOptions());
      _logResponse(response);
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}
