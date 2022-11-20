import 'package:flutter/material.dart';

import './models/meal.dart';
import './screens/filters_screen.dart';
import './screens/tabs_screen.dart';
import './screens/categories_screen.dart';
import './screens/category_meals_screen.dart';
import './screens/meal_detail_screen.dart';

import './dummy_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // Filtri dell'utente
  Map<String, bool> _filters = {
    'gluten': false,
    'lactose': false,
    'vegan': false,
    'vegetarian': false,
  };

  // Lista globale di ricette
  List<Meal> _availableMeals = DUMMY_MEALS;

  // Lista di ricette che l'utente ha segnalato come favoriti
  // (da inoltrare alla page delle tabs)
  List<Meal> _favoriteMeals = [];

  /*
   * Memorizzo come globali i filtri salvati dall'utente nella page dei filtri
   */
  void _setFilters(Map<String, bool> filters) {
    setState(() {
      _filters = filters;

      _availableMeals = DUMMY_MEALS.where((meal) {
        if(_filters['gluten'] && !meal.isGlutenFree)
          return false;
        if(_filters['lactose'] && !meal.isLactoseFree)
          return false;
        if(_filters['vegan'] && !meal.isVegan)
          return false;
        if(_filters['vegetarian'] && !meal.isVegetarian)
          return false;

        return true;
      }).toList();
    });
  }


  /*
   * Funzione che mette/toglie una ricetta dai preferiti
   *
   * ATTENZIONE:
   * il setState() qui fa il ri-rendering di tutta l'app...
   */
  void _toggleFavorite(String mealId) {
    // Capisco se la ricetta passata è già tra i preferiti
    final existingIndex = _favoriteMeals.indexWhere((meal) => meal.id == mealId);

    // Se è presente la rimuovo
    if (existingIndex >= 0) {
      setState(() {
        _favoriteMeals.removeAt(existingIndex);
      });
    // Altrimenti la aggiungo
    } else {
      setState(() {
        _favoriteMeals.add(_availableMeals.firstWhere((meal) => meal.id == mealId));
      });
    }
  }
  /*
   * Funzione che mi dice se la ricetta è già tra i favoriti
   */
  bool _isMealFavorite(String mealId) {
    return _favoriteMeals.any((meal) => meal.id == mealId);
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeliMeals',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        accentColor: Colors.amber,
        canvasColor: Color.fromRGBO(255, 254, 229, 1),
        fontFamily: 'Raleway',
        textTheme: ThemeData.light().textTheme.copyWith(
              body1: TextStyle(color: Color.fromRGBO(20, 51, 51, 1)),
              body2: TextStyle(color: Color.fromRGBO(20, 51, 51, 1)),
              title: TextStyle(fontSize: 20, fontFamily: 'RobotoCondensed', fontWeight: FontWeight.bold),
            ),
      ),


      // Albero di navigazione dell'app
      initialRoute: '/',
      routes: {
        '/': (ctx) => TabsScreen(_favoriteMeals), // Home = TabBar
        CategoryMealsScreen.routeName: (ctx) => CategoryMealsScreen(_availableMeals),
        MealDetailScreen.routeName: (ctx) => MealDetailScreen(_toggleFavorite, _isMealFavorite),
        FiltersScreen.routeName: (ctx) => FiltersScreen(_filters, _setFilters),
      },
      // Operazioni in caso di pagine non registrate in routes
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (ctx) => CategoriesScreen());
      },
      // Operazioni in caso di problemi con tutti i casi precedenti!
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (ctx) => CategoriesScreen());
      },
    );
  }
}
