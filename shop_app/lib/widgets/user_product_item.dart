import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../screens/edit_product_screen.dart';

/*
 * Widget del box del prodotto caricato dall'utente (in user_products_screen)
 */
class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    // Salvo lo Scaffold come proprietà perché mi serve usarlo in una funzione async
    // che utilizza una chiamata wait...
    final scaffold = ScaffoldMessenger.of(context);

    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
              onPressed: () async {
                try {
                  // Chiamo il metodo del provider
                  await Provider.of<Products>(context, listen: false).deleteProduct(id);
                } catch (error) {
                  // Mostro un avviso in basso con l'errore nella cancellazione
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text('Deleting failed!', textAlign: TextAlign.center),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
