import 'package:flutter/material.dart';

import '../screens/category_meals_screen.dart';

/*
 * Widget del box della categoria di ricette (nella homepage)
 */
class CategoryItem extends StatelessWidget {
  final String id;
  final String title;
  final Color color;

  CategoryItem(this.id, this.title, this.color);

  void selectCategory(BuildContext ctx) {
    /*
     * Navigator gestisce lo spostamento da una page all'altra
     *
     * Necessita del context per poter conoscere l'albero dei widget
     * Le pagine vengono gestite con uno Stack (push() e pop()), in questo caso devo passare manualmente i dati
     * oppure tramite naming
     *
     * MaterialPageRoute gestisce la transizione effettiva con le varie proprietà
     */
    // Metodo con le page gestite con tramite naming
    Navigator.of(ctx).pushNamed(
      CategoryMealsScreen.routeName,
      arguments: {
        'id': id,
        'title': title,
      },
    );

    // Metodo con push diretto
    /*Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return CategoryMealsScreen(id, title);
        },
      ),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    /*
     * InkWell è un Container cliccabile e stilizzabile
     */
    return InkWell(
      onTap: () => selectCategory(context),
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      // Box con lo sfondo sfumato ed i dettagli
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.7),
              color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.title,
        ),
      ),
    );
  }
}
