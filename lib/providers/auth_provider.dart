import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//todo 1 (next main)
class AuthProvider with ChangeNotifier {
  // String _token;
  // DateTime _expiryDate;
  // String _userId;

  Future<void> signup(String email, String password) async {
    const url = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDoMBZtOAhGfcgtuA7yvB5FoHwLUijFCAg';
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
}
