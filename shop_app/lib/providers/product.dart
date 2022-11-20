import 'dart:convert'; // Converte gli oggetti Dart in JSON

import 'package:flutter/foundation.dart'; // Mi permette di usare @required e ChangeNotifier
import 'package:http/http.dart' as http;


/*
 * Oggetto prodotto
 *
 * è mixata con la classe ChangeNotifier per ereditare i suoi metodi e le sue proprietà
 *
 * La utilizzo per triggerare i Listeners che sono in ascolto sul singolo prodotto
 * In questo modo, ad ogni modifica del prodotto (es: isFavorite) Flutter invoca il metodo build() del
 * relativo widget in ascolto.
 */
class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  /*
   * Metodi
   */
  // Inverto il valore del booleano isFavorite
  Future<void> toggleFavoriteStatus(String token, String userId) async {

    // Faccio un backup dello stato
    final oldStatus = isFavorite;

    isFavorite = !isFavorite;
    // Notifico il cambiamento ai widget in ascolto
    notifyListeners();

    // In Firebase ho una folder userFavorites con una lista per ogni utente di tutti i prodotti favoriti
    // Questa richiesta preleva il prodotto con id per l'utente userId
    final url = 'https://shopapp-flutter-91ab0-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      // Faccio l'update sul server
      final response = await http.put(url, body: json.encode(isFavorite));

      // Se ci sono problemi con la richiesta
      if (response.statusCode >= 400) {
        // Faccio il roll-back
        isFavorite = oldStatus;
        notifyListeners();
      }

    } catch (error) {
      // Faccio il roll-back
      isFavorite = oldStatus;
      notifyListeners();
    }

  }
}
