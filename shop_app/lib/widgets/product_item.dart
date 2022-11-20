import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';

/*
 * Widget per con il box del singolo prodotto (nella pagina shop: products_overview_screen.dart)
 */
class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /*
     * Prelevo le info del prodotto e del carrello dai rispettivi Provider
     * non rimango in ascolto del provider perché le info del widget non devono
     * essere modificate a run-time, ad eccezione dell'icona dei favoriti che,
     * infatti, è in un Consumer (rimane in ascolto solo per quella porzione di
     * albero dei widget)
     */
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    /*
     * ClipRRect modifica la forma del proprio child
     */
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      /*
         * GridTile gestisce i singoli elementi di una GridView()
         */
      child: GridTile(
        // Al click sulla foto vado alla pagina prodotto
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),

        // Footer del GridTile
        footer: GridTileBar(
          backgroundColor: Colors.black87,

          // Parte sinistra del footer
          /*
           * Consumer è l'alternativa di utilizzare un Provider,
           * gestisce l'ascolto a grana fine!
           *
           * In questo modo ho un widget padre che non rimane in ascolto e non viene modificato
           * ed un widget figlio (in questo caso l'icona dei preferiti) che rimane in ascolto
           * e viene modificato a run-time!
           *
           * il metodo builder di Consumer prende i dati dal context passato come parametro,
           * indico che gli passo un elemento product e posso passargli un elemento child.
           *
           * child indica un ulteriore figlio che deve rimanere escluso dall'ascolto
           * (potrei inserire una label vicino l'icona che non deve essere modificata
           */
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                product.toggleFavoriteStatus(authData.token, authData.userId);
              },
              color: Theme.of(context).accentColor,
            ),
          ),

          // Parte centrale del footer
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),

          // Parte destra del footer
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.adItem(product.id, product.price, product.title);

              /*
               * SnackBar di aggiunta prodotto al carrello
               */
              // Controllo il più vicino Scaffold che controlla la page
              // Tolgo la vecchia SnackBar
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              // Mostro la SnackBar con l'avviso
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Added item to cart!'),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              ));
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
