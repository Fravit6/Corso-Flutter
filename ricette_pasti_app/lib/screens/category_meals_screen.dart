import 'package:flutter/material.dart';

import '../widgets/meal_item.dart';
import '../models/meal.dart';

/*
 * Pagina dei pasti di una determinata categoria
 */
class CategoryMealsScreen extends StatefulWidget {
  // Salvo in una proprietà static const il nome della pagina per l'accesso
  // Evito in questo modo di dover riscrivere manualmente la stringa altrove
  static const routeName = '/category-meals';

  final List<Meal> availableMeals;

  CategoryMealsScreen(this.availableMeals);

  @override
  _CategoryMealsScreenState createState() => _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen> {

  String categoryTitle;
  List<Meal> displayedMeals;



  /*@override
  void initState() {
    super.initState();
  }*/


  /*
   * Viene chiamato prima di build() ma dopo initState()
   *
   * Mi serve per prelevare i dati reali delle ricette da mostrare
   *
   * Normalmente avrei inserito questo codice in initState() ma non posso farlo perché mi serve
   * prelevare info da context e non ne ho l'accesso in initState()
   */
  @override
  void didChangeDependencies() {
    // Prelevo i parametri passati dal widget che ha fatto partire il cambio di page
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    categoryTitle = routeArgs['title'];
    final categoryId = routeArgs['id'];

    // Prelevo tutte le ricette che contengono l'id della categoria nella lista di categorie
    displayedMeals = widget.availableMeals.where((meal) {
      return meal.categories.contains(categoryId);
    }).toList();

    super.didChangeDependencies();
  }

  /*
   * Rimuovo la ricetta che l'utente ha selezionato e ricarico la page con il setState()
   */
  void _removeMeal(String mealId) {
    setState(() {
      displayedMeals.removeWhere((meal) => meal.id == mealId);
    });
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
      ),
      body: ListView.builder(
        itemBuilder: (ctx, index) {
          return MealItem(
            id: displayedMeals[index].id,
            title: displayedMeals[index].title,
            imageUrl: displayedMeals[index].imageUrl,
            duration: displayedMeals[index].duration,
            complexity: displayedMeals[index].complexity,
            affordability: displayedMeals[index].affordability,
            //removeItem: () => _removeMeal(displayedMeals[index].id),
          );
        },
        itemCount: displayedMeals.length,
      ),
    );
  }
}
