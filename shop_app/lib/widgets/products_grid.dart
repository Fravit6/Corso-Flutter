import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/product_item.dart';

/*
 * Widget per la griglia dei prodotti nella pagina shop
 *
 * Questo widget è in ascolto del Provider di Prodotto!
 */
class ProductsGrid extends StatelessWidget {

  final bool showFavs;

  ProductsGrid(this.showFavs);


  @override
  Widget build(BuildContext context) {
    // Prelevo dal provider tutti i prodotti disponibili (o solo i favoriti)
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;

    // GridView.builder ottimizza il rendering dei children
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,

      // Elementi della griglia
      // Ad ogni elemento attacco un Provider che rimane in ascolto
      // sull'oggetto prodotto, in questo modo rilevo le modifiche e
      // inoltro il messaggio all'elemento della griglia rispettivo
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        //create: (c) => products[i],
        value: products[i],
        child: ProductItem(),
      ),

      // Aspetto estetico della griglia con un numero fissato di colonne
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
