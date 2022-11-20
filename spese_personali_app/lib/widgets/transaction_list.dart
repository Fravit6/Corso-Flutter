import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Lo utilizzo per formattare le date
import 'package:intl/date_symbol_data_local.dart'; // per avere le date in italiano

import '../models/transaction.dart';
import './transaction_list_item.dart';

/*
 * Widget che gestisce la lista di transactions
 */
class TransactionList extends StatelessWidget {
  final List<Transaction> _transactions;
  final Function _deleteTransaction; // ereditata da main.dart

  TransactionList(this._transactions, this._deleteTransaction);

  @override
  Widget build(BuildContext context) {
    // Salvo le proprietà di MediaQuery in una variabile per non calcolarle ad ogni utilizzo
    final mediaQuery = MediaQuery.of(context);

    // Imposto la lingua locale alle date...
    initializeDateFormatting('it_IT', null);

    /*
     * ListView è il widget che gestisce lo scrolling del contenuto.
     * é un metodo più veloce di creare
     *
     * Necessita di un padre con altezza nota!!
     * Non posso inserire il padre in un Expanded() o in un altro Container() con flex! (perché sovrascrivo la dimensione fissata)
     *
     * Posso creare ListView in due modi:
     *     - ListView(children: []):
     *          - crea una Column() in un SingleChildScrollView()
     *          - carica tutti i children alla creazione!
     *     - ListView.builder():
     *          - carica solo i children visibili nello spazio interessato!
     *          - devo passargli un itemBuilder con una funzione che Flutter richiama per ogni elemento di ListView (ne ho l'indice)
     *          - devo passargli un itemCount con il numero di elementi di ListView
     */
    return (_transactions.isEmpty)
        // Se non ci sono transaction
        ? LayoutBuilder(
            builder: (ctx, constraints) {
              return Column(
                children: <Widget>[
                  Text(
                    'Non ci sono ancora transazioni!',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  // Widget che uso come spazio vuoto (separatore)
                  const SizedBox(height: 20),
                  /*
                   * Container è uno dei principali widget
                   *
                   * Le dimensioni di Container di default sono quelle dall'unico elemento interno
                   * ma possono essere modificate a piacimento...
                   *
                   * Possiamo definire decoration che ci permette di stilizzare moltissimo il container
                   */
                  Container(
                      height: constraints.maxHeight * 0.6,
                      child: Image.asset(
                        'assets/images/waiting.png',
                        fit: BoxFit.cover, // L'immagine occupa tutto lo spazio del suo Container
                      )),
                ],
              );
            },
          )

        // Se ci sono transaction
        : ListView.builder(
            itemBuilder: (ctx, indexList) {
              return TransactionListItem(
                // Genero una key univoca per ogni elemento della lista
                // Attenzione:
                // key ha un bug con ListView.builder, usare ListView()!
                // key: ValueKey(_transactions[indexList].id),
                transaction: _transactions[indexList],
                mediaQuery: mediaQuery,
                deleteTransaction: _deleteTransaction,
              );
            },
            itemCount: _transactions.length,
          );
  }
}

