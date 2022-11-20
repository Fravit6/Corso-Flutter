import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Lo utilizzo per formattare le date
import 'package:intl/date_symbol_data_local.dart'; // per avere le date in italiano

import '../models/transaction.dart';


/*
 * Widget che gestisce l'elemento transaction della lista di transactions
 */
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;      // Oggetto transaction con i dati
  final Function deleteTransaction;   // Puntatore della funzione per l'eliminazione premendo il bottone
  final mediaQuery;                   // Dati mediaQuery (per non richiamare ogni volta MediaQuery.of(context))

  const TransactionListItem({
    @required this.deleteTransaction,
    @required this.mediaQuery,
    @required this.transaction,
  });



  /*
   * Cerchi con colori random:
   * utilizzo le key per identificare ogni elemento della lista, le key mi servono per 2 motivi:
   * il colore del cerchio non deve cambiare ad ogni build()
   * il colore del cerchio non deve cambiare quando elimino l'elemnto della lista precedente!
   * (forzo il collegamento tra l'albero dei widget e quello degli element (che conserva i vari State)
   *
   * Questa classe dovrebbe diventare Stateful
   *
   * Eliminato!
   */
  // Dovrei cambiare il costruttore
  /*const TransactionListItem({
    Key key,
    @required this.deleteTransaction,
    @required this.mediaQuery,
    @required this.transaction,
  }) : super(key: key);*/
  // Metodo da aggiungere
  /*@override
  void initState() {
    const availableColors = [
      Colors.red,
      Colors.black,
      Colors.blue,
      Colors.purple,
    ];

    _bgColor = availableColors[Random().nextInt(4)];
    super.initState();
  }*/




  @override
  Widget build(BuildContext context) {
    // Alternativa 1 con ListTile()
    /*
     * ListTile() gestisce gli elementi di una lista
     */
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 5,
      ),
      child: ListTile(
        // Elemento fissato in alto nella lista
        // CircleAvatar() gestisce un Container() circolare stilizzato
        leading: CircleAvatar(
          //backgroundColor: _bgColor,
          radius: 30,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: FittedBox(
                // .toStringAsFixed(2) taglia il numero alla seconda cifra decimale
                child: Text('€${transaction.amount.toStringAsFixed(2)}')),
          ),
        ),

        // Elemento centrale
        title: Text(
          transaction.title,
          style: Theme.of(context).textTheme.headline6,
        ),
        subtitle: Text(
          DateFormat.yMMMd('it_IT').format(transaction.date),
        ),

        // Elemento finale
        // Su schermi larghi mostro un bottone testo + icona
        // Sugli altri solo icona
        trailing: (mediaQuery.size.width > 460)
            ? FlatButton.icon(
                textColor: Theme.of(context).errorColor,
                icon: Icon(Icons.delete),
                // Il widget Text() non cambierà mai il contenuto quindi lo istanzio come const
                // in questo modo non creo una nuova istanza ad ogni build()
                label: const Text('Elimina'),
                onPressed: () => deleteTransaction(transaction.id),
              )
            : IconButton(
                icon: const Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () => deleteTransaction(transaction.id),
              ),
      ),
    );


    // Alternativa 2 con Card()
    /*return Card(
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Text(
                          // .toStringAsFixed(2) taglia il numero alla seconda cifra decimale
                          '${_userTransactions[indexList].amount.toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Sposto i children a sinistra
                        children: <Widget>[
                          Text(
                            _userTransactions[indexList].title,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy')
                                .format(_userTransactions[indexList].date),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );*/
  }
}
