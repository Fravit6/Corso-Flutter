import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// In cart.dart ho due classi:
// CartItem e Cart
// CartItem va in conflitto con la stessa classe di cart_item.dart
// Utilizzo "show" per importare la sola classe Cart da cart.dart
import '../providers/cart.dart' show Cart;
import '../providers/orders.dart';
import '../widgets/cart_item.dart';

/*
 * Pagina carrello (dall'AppBar in home)
 */
class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    // Prelevo dal provider le info sul carrello dell'utente
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart!'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),

                  // Spacer è un container che occupa il massimo spazio possibile
                  // Lo uso per distanziare gli elementi di Row
                  Spacer(),

                  // Chip è un container con i bordi tondi stilizzabile
                  Chip(
                    label: Text(
                      '${cart.totalAmount.toStringAsFixed(2)}€',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),

          SizedBox(height: 10),

          // ListView non funziona in una Column, quindi lo inserisco in un Expanded
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) => CartItem(
                // items di cart è uma Map<chiave, valore>
                // estraggo la lista dei valori e uso l'indice per identificare il mio prodotto
                cart.items.values.toList()[i].id,
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
                cart.items.values.toList()[i].title,
              ),
              itemCount: cart.itemCount,
            ),
          ),
        ],
      ),
    );
  }
}

/*
 * Bottone ORDER NOW
 */
class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false; // Se sto eseguendo l'ordine

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading == true)
          ? null // Se non ho nulla nel carrello o se sto già facendo l'ordine
          : () async {
              // Inizio animazione
              setState(() {
                _isLoading = true;
              });
              // Eseguo l'ordine
              await Provider.of<Orders>(context, listen: false).addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              );
              // Fine animazione
              setState(() {
                _isLoading = false;
              });
              widget.cart.clear();
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
