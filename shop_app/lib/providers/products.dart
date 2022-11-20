import 'dart:convert'; // Converte gli oggetti Dart in JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

/*
 * Classe Lista Prodotti Provider
 *
 * è mixata con la classe ChangeNotifier per ereditare i suoi metodi e le sue proprietà
 *
 * La utilizzo per triggerare i Listeners che sono in ascolto sulla lista dei prodotti dello shop
 * In questo modo, ad ogni modifica dei prodotti Flutter invoca il metodo build() del
 * relativo widget in ascolto.
 */
class Products with ChangeNotifier {
  // Lista di tutti i prodotti disponibili
  List<Product> _items = [
    /*Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];

  // Token dell'utente, mi serve per le chiamate a Firebase
  final String authToken;
  // Id Utente
  final String userId;

  Products(this.authToken, this.userId, this._items);


  /*
   * Getter
   */
  // Restituisco la List di tutti i prodotti come copia usando l'operatore "..."
  // i metodi in ascolto non devono modificare la lista originale!
  List<Product> get items {
    return [..._items];
  }

  // Restituisco la lista di prodotti con il flag isFavorite
  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  /*
   * Metodi
   */
  // Scarico i prodotti (dell'utente o tutti) dal server
  // In home devo mostrare tutti i prodotti, nella pagina di modifica solo
  // quelli di proprietà dell'attuale utente
  //
  // filterByUser è un parametro opzionale che indica se devo scaricare
  // i prodotti filtrati o tutti
  // Metodo asincrono (tutto il blocco viene racchiuso in un Future),
  // mi permette di utilizzare await
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = 'https://shopapp-flutter-91ab0-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      // Estraggo il body della risposta e ne faccio il cast
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      // Se non ci sono prodotti...
      if (extractedData == null) return;

      // Scarico anche la lista dei prodotti preferiti
      url = 'https://shopapp-flutter-91ab0-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteDate = json.decode(favoriteResponse.body);


      // Estraggo i singoli prodotti
      final List<Product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          price: prodData['price'],
          title: prodData['title'],
          description: prodData['description'],
          imageUrl: prodData['imageUrl'],
          // Se non ho favoriti metto false, se prodId è null metto false
          isFavorite: favoriteDate == null ? false : favoriteDate[prodId] ?? false,
        ));
      });

      _items = loadedProducts;
      notifyListeners();

    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Aggiungo un nuovo prodotto per l'utente corrente
  // Metodo asincrono (tutto il blocco viene racchiuso in un Future),
  // mi permette di utilizzare await
  Future<void> addProduct(Product product) async {
    // Invio il nuovo prodotto al Server in formato JSON
    final url = 'https://shopapp-flutter-91ab0-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    /*
     * http.post restituisce un oggetto Future (come promise in JS)
     * Quindi è una chiamata asincrona, ne rimango in attesa con await
     */
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId, // Presente solo in Firebase e non localmente
        }),
      );

      // Quando ricevo risposta dal server aggiungo il prodotto localmente
      final newProduct = Product(
        // In questo caso response è un JSON con l'id univoco del prodotto
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      //_items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print('Error while adding a product on the server:');
      print(error);
      throw error;
    }
  }

  // Cerca un prodotto by ID
  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // Modifica un prodotto
  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == newProduct.id);
    if (prodIndex >= 0) {

      final url = 'https://shopapp-flutter-91ab0-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      // http.patch = unisci i valori passati con quelli del server
      // i valori non passati a patch non verranno modificati
      await http.patch(url, body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'imageUrl': newProduct.imageUrl,
        'price': newProduct.price,
      }));

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('Error in updateProduct: Product not found in list!');
    }
  }

  // Elimina un prodotto
  Future<void> deleteProduct(String id) async {

    final url = 'https://shopapp-flutter-91ab0-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';

    // Salvo una copia in memoria del prodotto
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    // Lo elimino dalla lista in memoria
    _items.removeAt(existingProductIndex);
    notifyListeners();

    // Lo elimino dal server
    final response = await http.delete(url);

    // Se ho rilevato un errore
    if (response.statusCode >= 400) {
      // Lo re-inserisco nella lista in memoria
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }

    // Lo elimino dalla memoria
    existingProduct = null;
  }
}