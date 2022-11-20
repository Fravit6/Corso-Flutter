import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Lo utilizzo per formattare le date
import 'package:intl/date_symbol_data_local.dart'; // per avere le date in italiano

import './chart_bar.dart';
import '../models/transaction.dart';

/*
 * Gestisce il grafico con le statistiche
 */
class Chart extends StatelessWidget {
  final List<Transaction> recentTransaction;

  /*
   * Costruttore
   */
  Chart(this.recentTransaction);

  /*
   * Getter
   * (Un getter equivale ad una proprietà ottenuta dinamicamente alla chiamata)
   *
   * Crea la lista con spese effettuate giorno per giorno durante l'ultima settimana
   */
  List<Map<String, Object>> get groupedTransactionValues {
    // Eseguo un ciclo per ogni giorno della settimana
    return List.generate(7, (index) {
      // weekDay è l'etichetta con il giorno ottenuta sottraendo da now() il numero index del ciclo
      final weekDay = DateTime.now().subtract(Duration(days: index));

      // Calcolo il totale speso in questo giorno
      double totalSum = 0.0;
      for (int i = 0; i < recentTransaction.length; i++) {
        if (recentTransaction[i].date.day == weekDay.day &&
            recentTransaction[i].date.month == weekDay.month &&
            recentTransaction[i].date.year == weekDay.year)
          totalSum += recentTransaction[i].amount;
      }

      //print("day:" + DateFormat.E().format(weekDay).toString() + " - amount:" + totalSum.toString());
      initializeDateFormatting("it_IT", null);

      return {
        'day': DateFormat.E('it_IT').format(weekDay).substring(0, 1),
        'amount': totalSum
      };

    // Inverto l'ordine dei giorni
    }).reversed.toList();
  }

  /*
   * Getter
   * (Un getter equivale ad una proprietà ottenuta dinamicamente alla chiamata)
   *
   * Ottengo la spesa totale effettuata nell'ultima settimana, per il calcolo utilizzo la lista ottenuta
   * da groupedTransactionValues (un altro get)
   */
  double get totalSpending {
    /*
     * fold() cambia il contenuto di una lista seguendo la logica che gli passo come funzione
     * Il primo parametro di fold() è un valore di partenza, a questo valore viene aggiunto il valore che ottengo
     * dalla funzione che gli passo come secondo parametro
     *
     * La funzione accumula il risultato parziale in sum e itera su item (l'elemento della lista)
     */
    return groupedTransactionValues.fold(0.0, (sum, item) {
      return sum + item['amount'];
    });
  }

  @override
  Widget build(BuildContext context) {
    //print(groupedTransactionValues.toString());

    return Card(
        elevation: 6,
        margin: EdgeInsets.all(20),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: groupedTransactionValues.map((data) {
              return Flexible(
                flex: 1, // Tutti i widget avranno la stessa larghezza
                // Tutti i widget occuperanno il massimo spazio possibile (anche se questo elemento ha larghezza fissata)
                // Normalmente i widget occupano lo spazio minimo per il loro contenuto
                // L'alternativa è .loose che assegna il minimo spazio possibile (in base al contenuto)

                // invece di impostare FlexFit.tight avrei potuto sostituire l'intero Flexible() con Expanded() (senza poi specificare fit)
                fit: FlexFit.tight,

                // ChartBar vuole i dati del giorno e la percentuale di spesa rispetto alla settimana
                child: ChartBar(
                  data['day'],
                  data['amount'],
                  (totalSpending == 0.0)
                      ? 0.0
                      : (data['amount'] as double) / totalSpending,
                ),
              );
            }).toList(),
          ),
        ),
    );
  }
}
