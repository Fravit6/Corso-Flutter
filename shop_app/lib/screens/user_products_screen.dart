import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';

/*
 * Pagina dei prodotti inseriti dall'utente
 */
class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  // Funzione chiamata scorrendo verso il basso la lista
  // Aggiorna i prodotti dell'utente corrente
  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // Prelevo i prodotti dal Provider
    // NON lo uso qui perché uso il FutureBuilder!
    //final productsData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),

      drawer: AppDrawer(),

      // FutureBuilder ricrea il widget appena il provider notifica una modifica
      // sull'oggetto passato a future
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting
            // Loading dei prodotti
            ? Center(child: CircularProgressIndicator())
            /*
             * Tutto il contenuto della pagina è in un widget RefreshIndicator
             * Passo al metodo onRefresh una funzione che restituisce un Future
             *
             * Posso scorrere verso il basso per aggiornare i prodotti all'interno
             */
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),

                // Consumer gestisce i widget sottostanti e li aggiorna quando ci sono modifiche
                child: Consumer<Products>(
                  builder: (ctx, productsData, _) => Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: productsData.items.length,
                      itemBuilder: (_, i) => Column(
                        children: <Widget>[
                          UserProductItem(
                            productsData.items[i].id,
                            productsData.items[i].title,
                            productsData.items[i].imageUrl,
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
