import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId{
    return _userId!;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyByzCJQtRqjgD5p3AiemPAK1tyXnqlCGdY';
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
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      notifyListeners();
      _autoLogout();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void logout () {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null){
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }
  void _autoLogout () {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
   final timeToExpiry =  _expiryDate?.difference(DateTime.now()).inSeconds;
   _authTimer =  Timer(Duration(seconds: timeToExpiry!), logout);
  }

// Future<void> signup(String email, String password) async {
// const url =
//    'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyByzCJQtRqjgD5p3AiemPAK1tyXnqlCGdY';
// final response = await http.post(
//    Uri.parse(url),
//    body: json.encode(
//    {
//   'email': email,
//  'password': password,
// 'returnSecureToken' : true,
//},
//),
// );
}
// Future<void> login (String email, String password) async {
//   const url = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyByzCJQtRqjgD5p3AiemPAK1tyXnqlCGdY';
//   final response = await http.post(
//      Uri.parse(url),
//      body: json.encode(
//      {
//         'email': email,
//        'password': password,
//         'returnSecureToken' : true,
//        },
//      ),
//    );

//  }
