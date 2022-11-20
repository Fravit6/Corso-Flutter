import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

/*
 * Widget del prodotto nella pagina carrello (in cart_screen)
 */
class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    /*
     * Dismissible permette di eliminare l'elemento con uno swipe orizzontale
     *
     * Necessita di una key per rendere l'elemento unico all'interno dell'albero dei widget
     * Imposto come unico swipe quello destra>sinistra
     */
    return Dismissible(
      // Proprietà Dismissible
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to remove the item form the cart?'),
            actions: <Widget>[
              FlatButton(child: Text('No'), onPressed: () {
                // Chiudo l'alert e faccio il return false
                Navigator.of(ctx).pop(false);
              },),
              FlatButton(child: Text('Yes'), onPressed: () {
                // Chiudo l'alert e faccio il return true
                Navigator.of(ctx).pop(true);
              },),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },

      // Stile Dismissible
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 36,
        ),
      ),

      // Contenuto Dismissible
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: FittedBox(child: Text('$price€')),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: ${price * quantity}€'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
