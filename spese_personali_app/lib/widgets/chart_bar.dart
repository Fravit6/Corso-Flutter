import 'package:flutter/material.dart';

/*
 * Widget per le barre grafiche verticali del grafico delle spese settimanali
 */
class ChartBar extends StatelessWidget {
  final String label; // Etichetta
  final double spendingAmount; // Cifra Spesa
  final double spendingPctOfTotal; // % in base alla settimana

  /*
   * Costruttore
   *
   * Lo dichiaro di tipo const perché tutti i parametri sono final ed una volta
   * eseguito il rendering della ChartBar, questa rimane immutabile fino a nuova creazione!!
   *
   * Con questo costruttore posso ottenere facilmente il valore delle proprietà scrivendo:
   * ChartBar.label (come si fa per Colors.red), ovviamente, in questo modo non posso assegnare
   * nuovi valori alle proprietà!
   *
   * Alla fine, quindi, l'unico modo che ho per sostituirne i valori è quello di ricreare da zero
   * una nuova istanza di ChartBar() ma questo avviene in automatico ed è proprio quello che voglio!
   */
  const ChartBar(this.label, this.spendingAmount, this.spendingPctOfTotal);

  @override
  Widget build(BuildContext context) {
    /*
     * LayoutBuilder() è il widget che gestisce il rendering del widget contenuto
     *
     * Ha una proprietà builder alla quale dobbiamo passare un context e constraints,
     * uso constraints per calcolare le dimensioni del widget contenuto
     *
     * es: constraints.maxHeight equivale all'altezza massima che il mio widget può occupare
     * in questo modo posso impostare altezze relative in percentuale dei vai widget che lo compongono
     */
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(
          children: <Widget>[
            // FittedBox restringe il contenuto affinché non vada in overflow rispetto al contenitore
            // In questo caso il testo non va a capo ma si restringe
            Container(
              height: constraints.maxHeight * 0.15,
              child: FittedBox(
                child: Text('€${spendingAmount.toStringAsFixed(0)}'),
              ),
            ),
            SizedBox(height: constraints.maxHeight * 0.05),
            // Container di tutta la barra verticale
            Container(
              height: constraints.maxHeight * 0.6,
              width: 10,
              /*
           * Stack gestisce più widget uno sopra l'altro (sovrapposti)
           *
           * Qui inserisco il Container grigio con lo sfondo (per indicare l'intera barra)
           * ed il Container colorato di altezza variabile (per indicare la spesa del giorno)
           */
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      color: Color.fromRGBO(220, 220, 220, 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  /*
               * FractionallySizedBox crea un box di altezza variabile
               * Gestisco l'altezza con l'heightFactor che prende un valore decimale [0-1]
               * All'interno ho un semplice Container colorato
               */
                  FractionallySizedBox(
                    heightFactor: spendingPctOfTotal,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: constraints.maxHeight * 0.05),
            Container(
              height: constraints.maxHeight * 0.15,
              child: FittedBox(child: Text(label)),
            ),
          ],
        );
      },
    );
  }
}
