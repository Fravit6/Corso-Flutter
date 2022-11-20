import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';

/*
 * Enumeratore del filtro opzioni
 */
enum FilterOption {
  Favorites,
  All,
}

/*
 * Page shop con i prodotti
 */
class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  // Memorizzo nel widget la scelta dell'utente su quali prodotti visualizzare
  bool _showOnlyFavorites = false;
  bool _isInit = true; // Se ho già fatto il rendering del widget
  bool _isLoading = false; // Se sto caricando i prodotti

  // All'avvio scarico i dati dei prodotti
  @override
  void initState() {
    //Provider.of<Products>(context).fetchAndSetProducts(); // QUI NON FUNZIONA!
    // Dovrei fare così:
    /*Future.delayed(Duration.zero).then((_) {
      Provider.of<Products>(context).fetchAndSetProducts();
    });*/
    // Uso didChangeDependencies()...
    super.initState();
  }

  // Dopo che il widget è stato inizializzato
  @override
  void didChangeDependencies() {
    // Qui ci arrivo diverse volte...
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: <Widget>[
          /*
           * PopupMenuButton gestisce un menu verticale a comparsa
           *
           * è costituito da vari item che hanno un valore e gestisco
           * l'interazione grazie al metodo onSelected
           */
          PopupMenuButton(
            onSelected: (FilterOption selectedValue) {
              setState(() {
                if (selectedValue == FilterOption.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOption.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOption.All,
              ),
            ],
          ),

          // Sezione Carrello
          /*
           * Tutta la sezione è in un Consumer che rimane in ascolto delle modifiche
           * Il valore da dover modificare dinamicamente è il numero di elementi presenti
           * nel carrello (passato a value)
           *
           * Gli altri elementi del widget Badge sono passati a child tramite ch
           * ch è il child (stesso nome ma cose diverse) di Consumer ed indica gli elementi
           * che non sono affetti dall'ascolto di Cart.
           *
           * In pratica sto dicendo:
           * Il valore di Badge deve cambiare dinamicamente grazie al Consumer,
           * le componenti grafiche del widget Badge non devono cambiare quindi le inserisco nel
           * child di Consumer
           */
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
