import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/splash_screen.dart';
import './screens/auth_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /*
     * Wrappo l'intera App con i Provider:
     *
     * In questo modo tutto l'albero dei widget che partono da MaterialApp possono
     * usare e trasferire prodotti e il carrello, e creare nuovi metodi che rimangono in ascolto
     *
     * Ogni volta che i prodotti verranno modificati, verrà invocato il metodo build()
     * per i soli widget in ascolto e non dell'intera App
     */
    return MultiProvider(
      providers: [
        /*
         * Qui non uso la notazione .value per motivi di efficienza,
         * perché è la prima volta che creo l'oggetto del provider
         *
         * Il ProxyProvider mi permette di inoltrare parametri che avrò solo
         * successivamente alla build del widget (il token dell'utente).
         * Per poterlo fare devo impostarlo come discendente del Provider di Auth.
         * In questo modo il ProxyProvider di Products rimane in ascolto del Provider di Auth
         * ed eseguirà il re-build ad ogni cambiamento in Auth.
         *
         * Al metodo update di ProxyProvider gli passo un parametro (auth) da inoltrare alla classe Products
         * ed una versione dei dati (previousProducts) della classe Product precedente alla modifica del Provider Auth
         */
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],

      // Quando qualcosa dell'autenticazione cambia
      // faccio il re-build dell'app e cambio la home
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),

          // Se l'utente è autenticato lo indirizzo alla pagina con i prodotti
          home: auth.isAuth
              ? ProductsOverviewScreen()
              // Altrimenti provo l'autoLogin con i dati memorizzati sul device
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen() // Mentre viene eseguito l'autoLogin mostro una transizione
                          : AuthScreen(),  // Se il login fallisce mostro la pagina per il login manuale
                ),

          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
