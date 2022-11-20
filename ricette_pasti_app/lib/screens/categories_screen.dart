import 'package:flutter/material.dart';

import '../dummy_data.dart';
import '../widgets/category_item.dart';

/*
 * Pagina Categorie (homepage app!)
 */
class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /*
     * GridView gestisce i children a mosaico prendendoli da DUMMY_CATEGORIES in "dummy_data.dart"
     */
    return Container(
      child: GridView(
        padding: const EdgeInsets.all(25),
        children: DUMMY_CATEGORIES
            .map(
              (catData) =>
                  CategoryItem(catData.id, catData.title, catData.color),
            ).toList(),

        // Questo mostro gestisce il rendering degli elementi e lo scroll
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          // Ogni elemento è largo 200px e devo tenerlo fisso per il rendering
          maxCrossAxisExtent: 200,
          // Ogni elemento ha una proporzione di 3x2
          childAspectRatio: 3 / 2,
          // Margini tra gli elementi
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
      ),
    );
  }
}
