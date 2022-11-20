import 'dart:convert'; // Converte gli oggetti Dart in JSON

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

/*
 * Oggetto singolo ordine
 */
class OrderItem {
  final String id; // L'id è la data dell'ordine
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

/*
 * Oggetto lista ordini dell'utente
 *
 * è mixata con la classe ChangeNotifier per ereditare i suoi metodi e le sue proprietà
 *
 * La utilizzo per triggerare i Listeners che sono in ascolto sugli ordini
 * In questo modo, ad ogni nuovo ordine Flutter invoca il metodo build() del
 * relativo widget in ascolto.
 */
class Orders with ChangeNotifier {
  // Lista di tutti gli ordini dell'utente
  List<OrderItem> _orders = [];
  // Token utente di Firebase
  final String authToken;

  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  /*
   * Getters
   */
  List<OrderItem> get orders {
    return [..._orders];
  }

  /*
   * Metodi
   */
  // Scarico gli ordini dell'utente dal server
  Future<void> fetchAndSetOrders() async {
    final url = 'https://shopapp-flutter-91ab0-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);

    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    // Se non ci sono ordini...
    if (extractedData == null) return;

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        // Scorro la lista di prodotti ottenuta dal server
        // e creo gli oggetti CartItem per memorizzarli in locale
        products: (orderData['products'] as List<dynamic>)
            .map(
              (item) => CartItem(
                id: item['id'],
                title: item['title'],
                quantity: item['quantity'],
                price: item['price'],
              ),
            )
            .toList(),
      ));
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  // Creo un nuovo ordine
  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://shopapp-flutter-91ab0-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }));

    // Inserisco in cima alla lista
    _orders.insert(
      0,
      OrderItem(
        // Prendo l'id generato da firebase
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timestamp,
      ),
    );

    notifyListeners();
  }
}
