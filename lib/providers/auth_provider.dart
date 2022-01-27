import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  // String _token;
  // DateTime _expiryDate;
  // String _userId;

  //todo 1
  Future<void> _authenticate({
    required String email,
    required String password,
    required String segmentUrl,
  }) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$segmentUrl?key=AIzaSyDoMBZtOAhGfcgtuA7yvB5FoHwLUijFCAg';
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

    print(response.body);
  }

  //todo 2
  Future<void> signup(String email, String password) async {
    return _authenticate(
      email: email,
      password: password,
      segmentUrl: 'signUp',
    );
  }

  //todo 3 (next auth_screen)
  Future<void> login(String email, String password) async {
    return _authenticate(
      email: email,
      password: password,
      segmentUrl: 'signInWithPassword',
    );
  }
}
