import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

/*
 * Page del singolo prodotto (accessibile dalla pagina shop: products_overview_screen.dart)
 */
class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    // Prelevo l'id del prodotto dagli argomenti delle Named Routes
    final productId = ModalRoute.of(context).settings.arguments as String;

    // Prelevo i dati del prodotto dal Provider sfruttando l'id passato delle Named Routes
    final loadedProduct = Provider.of<Products>(
      context,
      // Una volta creata la pagina del prodotto non serve rimanere in ascolto del provider
      // perché non mi servirà aggiornare l'intero widget se un altro prodotto viene modificato
      listen: false,
    ).findById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Foto prodotto
            Container(
              width: double.infinity,
              height: 300,
              child: Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),

            // Prezzo Prodotto
            SizedBox(height: 10),
            Text(
              '${loadedProduct.price}€',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),

            // Descrizione Prodotto
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
