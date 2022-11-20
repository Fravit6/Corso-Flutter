import 'package:flutter/material.dart';

import '../screens/meal_detail_screen.dart';
import '../models/meal.dart';

/*
 * Widget per il box della singola ricetta
 *
 * Mostrato in una lista di ricette nella pagina della categoria
 */
class MealItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final int duration;
  final Complexity complexity;
  final Affordability affordability;
  //final Function removeItem;

  MealItem({
    @required this.id,
    @required this.title,
    @required this.imageUrl,
    @required this.duration,
    @required this.complexity,
    @required this.affordability,
    //@required this.removeItem,
  });

  /*
   * Getter della complessità
   * (Complexity è un enum e devo trasformare i valori numerici in testo)
   */
  String get complexityText {
    switch (complexity) {
      case Complexity.Simple:
        return 'Simple';
        break;
      case Complexity.Challenging:
        return 'Challenging';
        break;
      case Complexity.Hard:
        return 'Hard';
        break;
      default:
        return 'Unknown';
    }
  }

  String get affordabilityText {
    switch (affordability) {
      case Affordability.Affordable:
        return 'Affordable';
        break;
      case Affordability.Pricey:
        return 'Pricey';
        break;
      case Affordability.Luxurious:
        return 'Luxurious';
        break;
      default:
        return 'Unknown';
    }
  }

  /*
   * Cambia pagina e vai alla pagina della ricetta
   *
   * Utilizzo il .then() per accodare funzioni che verranno svolte in futuro
   * quando tornerò indietro dalla pagina della ricetta. In questo caso lo utilizzo per
   * fare cose quando l'utente preme sul bottone di elimina ricetta, infatti da quel bottone
   * invio l'id della ricetta e lo ricevo qui nel .then().
   *
   * Attenzione si può tornare qui anche se l'utente preme il tasto back dalla pagina della ricetta!
   */
  void selectMeal(BuildContext context) {
    Navigator.of(context).pushNamed(
      MealDetailScreen.routeName,
      arguments: id,
    ).then((result) {
      // Se l'utente è tornato indietro dal bottone elimina
      // result == id ricetta
      // Quindi rimuovo il box della ricetta dalla lista
      //if (result != null)
        //removeItem();
    });
  }

  @override
  Widget build(BuildContext context) {
    /*
     * InkWell è un Container cliccabile e stilizzabile
     */
    return InkWell(
      onTap: () => selectMeal(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            /*
             * Stack è widget tridimensionale che posiziona più widget uno sopra l'altro
             */
            Stack(
              children: <Widget>[
                /*
               * ClipRRect taglia il widget contenuto in una certa forma
               * Qui lo utilizzo per tagliare gli spigoli della foto
               *
               * Uso anche il widget Positioned che è un container in position absolute
               * del quale posso modificare a mio piacimento la posizione rispetto al padre
               */
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 20,
                  // Inserisco un Container per non far fuoriuscire il testo
                  child: Container(
                    width: 300,
                    color: Colors.black54,
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 20,
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                      // Se il testo dovesse essere troppo lo nascondo...
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.schedule),
                      SizedBox(width: 6),
                      Text('$duration min'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Icon(Icons.work),
                      SizedBox(width: 6),
                      Text(complexityText),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Icon(Icons.attach_money),
                      SizedBox(width: 6),
                      Text(affordabilityText),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
