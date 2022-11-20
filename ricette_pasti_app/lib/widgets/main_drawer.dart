import 'package:flutter/material.dart';

import '../screens/filters_screen.dart';

/*
 * Widget menu laterale app (raggiungibile da hamburger)
 */
class MainDrawer extends StatelessWidget {
  Widget buildListTile(String text, IconData icon, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        text,
        style: TextStyle(
            fontFamily: 'RobotoCondensed',
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: <Widget>[
        Container(
          height: 120,
          width: double.infinity,
          padding: EdgeInsets.all(20),
          // Allineo i children al centro sinistra
          alignment: Alignment.centerLeft,
          color: Theme.of(context).accentColor,
          child: Text(
            'Cooking Up!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),

        // Spazio vuoto
        const SizedBox(
          height: 20,
        ),

        // Voci menu
        buildListTile(
          'Meals',
          Icons.restaurant,
          () {
            // Devo cambiare page e svuotare lo Stack delle page
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        buildListTile(
          'Filter',
          Icons.settings,
          () {
            // Devo cambiare page e svuotare lo Stack delle page
            Navigator.of(context).pushReplacementNamed(FiltersScreen.routeName);
          },
        ),
      ],
    ));
  }
}
