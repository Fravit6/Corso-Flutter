import 'package:flutter/material.dart';

/*
 * Widget per le domande del questionario
 */
class Domanda extends StatelessWidget {
  /*
   * Proprietà del widget
   *
   * Sono final perché, dopo l'inizializzazione, non possono più essere modificate
   * (il widget è Stateless...)
   */
  final String testoDomanda;

  /*
   * Costruttore del widget
   *
   * Utilizzo la forma abbreviata con "this" per assegnare il valore passato in input
   * alla proprietà della classe
   */
  Domanda(this.testoDomanda);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Assegno larghezza 100% rispetto al padre
      width: double.infinity,
      // .all è uno dei costruttori di EdgeInsets()
      margin: EdgeInsets.all(10),
      child: Text(
        testoDomanda,
        style: TextStyle(fontSize: 28),
        textAlign: TextAlign.center,
      ),
    );
  }
}
