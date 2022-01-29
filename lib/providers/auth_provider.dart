import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/http_exception.dart';

class AuthProvider with ChangeNotifier {

  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer; //todo 1


  bool get isAuth{
    return token != null;
  }

  String get userId{
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
      _autoLogout(); //todo 4 finish
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

  void logout(){
    _token = null;
    _userId = null;
    _expiryDate = null;

    //todo 3
    if(_authTimer !=null){
      _authTimer?.cancel();
      _authTimer = null;
    }

    notifyListeners();
  }

  //todo 2
  void _autoLogout() {

    if(_authTimer !=null){
      _authTimer?.cancel();
    }

    final timeToExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
      Duration(seconds: timeToExpiry ?? 0),
      logout,
    );
  }
}
