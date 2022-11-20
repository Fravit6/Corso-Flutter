import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

/*
 * Pagina con gli ordini dell'utente
 * Accessibile dal Drawer (app_drawer)
 */
class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),

      /*
       * FutureBuilder è un widget speciale
       *
       * FutureBuilder prende un Future come parametro e ne rimane in ascolto
       * Permette di eseguire diverse istanze di build in base al valore assunto
       * dal Future
       */
      body: FutureBuilder(
        // Il Future qui è la lista di ordini del server
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {

          // Se la richiesta dei dati è in corso
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            // Mostro il loader
            return Center(child: CircularProgressIndicator());
          } else {

            // Controllo se ci sono stati errori con la richiesta
            if (dataSnapshot.error != null) {
              // Mostra un messaggio di errore
            } else {
              // Faccio il rendering di un Consumer che rimane in ascolto sugli ordini
              // Non faccio il rendering di tutta la pagina ma solo di questa sezione
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, i) => OrderItem(
                    orderData.orders[i],
                  ),
                ),
              );
            }
          }
          return null;

        },
      ),
    );
  }
}
