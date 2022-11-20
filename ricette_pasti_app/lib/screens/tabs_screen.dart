import 'package:flutter/material.dart';

import '../models/meal.dart';
import './categories_screen.dart';
import './favorites_screen.dart';
import '../widgets/main_drawer.dart';


/*
 * Widget che gestisce la TabBar (footer app con i collegamenti ad altre pagine)
 *
 * Può essere posta fixed in basso o in alto subito sotto l'AppBar
 *
 * In entrambi i casi la TabBar funge da Container delle pagine mostrate
 * Non mi serve più uno Scaffold per ogni pagina ma dovrò gestire solo il contenuto in un normale Container
 */
class TabsScreen extends StatefulWidget {

  // Lista di ricette preferite (da inoltrare alla page relativa)
  final List<Meal> favoriteMeals;


  TabsScreen(this.favoriteMeals);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {

  // Lista delle pagine linkate nelle tab
  List<Map<String, Object>> _pages;
  // Pagina selezionata dall'utente
  int _selectedPageIndex = 0;

  /*
   * Funzione per modificare lo stato del Widget e memorizzare la tab premuta
   */
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }


  @override
  void initState() {
    _pages = [
      {'page': CategoriesScreen(), 'title': 'Categories'},
      {'page': FavoritesScreen(widget.favoriteMeals), 'title': 'Your Favorite'},
    ];
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    /*
     * Caso 1) Fissata in alto subito dopo l'AppBar
     *
     * Devo impostarla come homepage dell'app
     * (o impostarla manualmente per le pagine in cui mi interessa inserirla)
     *
     * Gestisce in automatico lo switch dei contenuti interni grazie a TabBarView()
     *
     * In questo caso la TabBar funge da Container delle pagine mostrate sotto
     * Non mi serve più uno Scaffold per ogni pagina ma dovrò gestire solo il contenuto in un normale Container
     */
    /*return DefaultTabController(
      // Devo comunicare quante tab ci sono
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Meals'),
          // Qui definisco l'aspetto estetico delle tab
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.category),
                text: 'Categories',
              ),
              Tab(
                icon: Icon(Icons.star),
                text: 'Favorites',
              ),
            ],
          ),
        ),

        // Qui collego una page ad una specifica tab
        // Il resto lo fa Flutter in automatico
        body: TabBarView(children: <Widget>[
          CategoriesScreen(),
          FavoritesScreen(),
        ],),
      ),
    );*/




    /*
     * Caso 2) Fissata in basso
     *
     * Deve trovarsi in un Widget Stateful!
     */
    return Scaffold(
      appBar: AppBar(
        title: Text(_pages[_selectedPageIndex]['title']),
      ),
      // Menu laterale da hamburger
      drawer: MainDrawer(),
      body: _pages[_selectedPageIndex]['page'], // Mostra la pagina che è stata selezionata
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage, // Cambia pagina!
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Theme.of(context).accentColor,
        // Memorizzo quale tab devo mostrare come "attiva"
        currentIndex: _selectedPageIndex,
        // Le tab hanno un effetto simile ad uno "slider"...
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.category),
            title: Text('Categories'),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.star),
            title: Text('Favorites'),
          ),
        ],
      ),
    );
  }
}
