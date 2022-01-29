import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/http_exception.dart';

class AuthProvider with ChangeNotifier {

  String? _token;
  DateTime? _expiryDate;
  String? _userId;


  bool get isAuth{
    return token != null;
  }

  String get userId{ //todo 5 (next product_providers)
    return _userId??'';
  }

  String? get token{
    if(_expiryDate != null && _expiryDate!.isAfter(DateTime.now()) && _token!= null){
      return _token??'';
    }
    return null;
  }

  Future<void> _authenticate({
    required String email,
    required String password,
    required String segmentUrl,
  }) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$segmentUrl?key=AIzaSyDoMBZtOAhGfcgtuA7yvB5FoHwLUijFCAg';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);
      if(responseData['error'] != null){
        throw HttpException(message: responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(
      email: email,
      password: password,
      segmentUrl: 'signUp',
    );
  }

  Future<void> login(String email, String password) async {
    return _authenticate(
      email: email,
      password: password,
      segmentUrl: 'signInWithPassword',
    );
  }
}
