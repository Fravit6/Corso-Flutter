import 'dart:convert';
import 'dart:async'; // Per il timer

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Per memorizzare i dati sul device

import '../models/http_exception.dart';

/*
 * Provider delle operazioni tra utente e Firebase
 */
class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  /*
   * Getter
   */
  // Controllo se l'attuale utente è autenticato
  bool get isAuth {
    return token != null;
  }

  // Ottengo la stringa token di Firebase
  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()))
      return _token;

    return null;
  }

  String get userId {
    return _userId;
  }

  /*
   * Metodi
   */
  // Registrazione di un nuovo utente
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  // Login
  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  // Unica funzione per login e registrazione
  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final String apiKey =
        'AIzaSyAg4_xM-AGRvJe_QLxqzw1UmQtEBezOi6s'; // Presa da Firebase
    final String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$apiKey';

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      // Controllo gli errori (es: email già iscritta)
      final responseData = json.decode(response.body);
      if (responseData['error'] != null)
        throw HttpException(responseData['error']['message']);

      // Salvo il token di Firebase
      _token = responseData['idToken'];
      // Salvo l'id dell'utente di Firebase
      _userId = responseData['localId'];
      // Imposto la scadenza del token
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));

      // Faccio partire il timer per il logout
      _autoLogout();

      notifyListeners();

      // Memorizzo i dati sul device
      final prefs = await SharedPreferences.getInstance();
      // se ho oggetti complessi li devo convertire in JSON
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);

      //print(json.decode(response.body));
    } catch (error) {
      throw error;
    }
  }

  // AutoLogin all'avvio
  // Restituisce un Future che a sua volta restituisce un booleano
  // che indica se l'autoLogin è andato a buon fine o meno
  Future<bool> tryAutoLogin() async {
    // Prelevo le informazioni dal device
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData'))
      return false;
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;

    // Controllo se il token è scaduto
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now()))
      return false;

    // Sostituisco i valori con quelli del dispositivo
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;

    notifyListeners();

    // Avvio il timer per il logout automatico
    _autoLogout();

    // Confermo l'avvenuto login
    return true;
  }



  // Invalido il token per eseguire il logout
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    // Cancello i dati memorizzati sul device per evitare l'autoLogin
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    //prefs.clear() // cancella tutto
  }

  // Timer automatico per il logout alla scadenza del token
  void _autoLogout() {
    if (_authTimer != null) _authTimer.cancel();

    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
