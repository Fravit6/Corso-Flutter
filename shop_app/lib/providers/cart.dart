import 'package:flutter/foundation.dart';

/*
 * Oggetto item contenuto nel Carrello
 *
 * Simile ad un prodotto ma con un id differente ed altre info utili al checkout
 */
class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

/*
 * Oggetto Carrello
 *
 * è mixata con la classe ChangeNotifier per ereditare i suoi metodi e le sue proprietà
 *
 * La utilizzo per triggerare i Listeners che sono in ascolto sul carrello
 * In questo modo, ad ogni modifica dei prodotti Flutter invoca il metodo build() del
 * relativo widget in ascolto.
 */
class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  /*
   * Getter
   */
  // Restituisco la Map di tutti i prodotti nel carrello come copia usando l'operatore "..."
  // i metodi in ascolto non devono modificare la lista originale!
  Map<String, CartItem> get items {
    return {..._items};
  }

  // Restituisco il numero di prodotti nel carrello
  int get itemCount {
    return _items.length;
  }

  // Restituisco il totale del carrello
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  /*
   * Metodi
   */
  // Aggiungo prodotto al carrello
  void adItem(String productId, double price, String title) {
    // Se nel carrello c'è già il prodotto
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity + 1,
            price: existingCartItem.price),
      );

      // Altrimenti l'aggiungo ex novo
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            quantity: 1,
            price: price),
      );
    }

    notifyListeners();
  }

  // Rimuovo gruppo prodotto dal carrello (anche se la quantità è >1)
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Rimuovo singolo prodotto dal carrello (quantità--)
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
              (existingCartItem) =>
              CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity - 1,
              ));
    } else {
      _items.remove(productId);
    }

    notifyListeners();
  }

  // Svuota carrello
  void clear() {
    _items = {};
    notifyListeners();
  }
}
