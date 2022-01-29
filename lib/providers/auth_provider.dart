import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/http_exception.dart';

class AuthProvider with ChangeNotifier {

  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;


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
      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate?.toIso8601String(),
        },
      );

      prefs.setString('userData', userData);

    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData')??'') as Map<String,dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);

    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }

    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
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

  Future<void> logout() async{
    _token = null;
    _userId = null;
    _expiryDate = null;

    if(_authTimer !=null){
      _authTimer?.cancel();
      _authTimer = null;
    }

    notifyListeners();

    //todo 1 (next app_drawer)
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

  }

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
