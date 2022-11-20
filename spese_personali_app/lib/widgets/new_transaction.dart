import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Lo utilizzo per formattare le date
import 'package:intl/date_symbol_data_local.dart'; // per avere le date in italiano

import './adaptive_flat_button.dart';

/*
 * Widget che mostra il form per l'inserimento di una nuova transaction
 */
class NewTransaction extends StatefulWidget {
  // Questa è la funzione (passata in input al costruttore) che fa il submit dei dati del form
  // Questa e le altre proprietà possono essere usate anche dalla classe State (in basso)
  // chiamandole con widget.nomeProprietà
  final Function _addNewTransaction;

  NewTransaction(this._addNewTransaction);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  // Queste proprietà sono gestite dai controller dei widget di input
  // In questo modo riesco ad inserire i valori anche se le proprietà sono final, anche se il widget è Stateless...
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate;

  /*
   * Inoltro dei dati del form
   */
  void _submitData() {
    // Se non è stato inserito un valore
    if (_amountController.text.isEmpty) return;

    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    // Controllo l'input
    if (enteredTitle.isEmpty || enteredAmount <= 0 || _selectedDate == null)
      return;

    // eseguo "da remoto" la funzione passandole i valori presi da input
    widget._addNewTransaction(enteredTitle, enteredAmount, _selectedDate);

    // Utilizzo il Navigator per chiudere il pannello di inserimento della transaction
    Navigator.of(context).pop();
  }

  /*
   * Mostra il DatePicker nell'app
   *
   * showDatePicker() è la funzione di Flutter per poterlo fare
   *
   * Quello che viene inserito dall'utente viene passato alla funzione then() che rimane in attesa,
   * non rimane in attesa l'intera app ma solo quella funzione. (Utile anche per le richieste HTTP)
   */
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) // Se l'utente ha premuto "Cancella"
        return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Imposto la lingua locale alle date...
    initializeDateFormatting('it_IT', null);

    // SingleChildScrollView permette al widget contenuto di avere lo scroll verticale
    return SingleChildScrollView(
      /*
       * Card è uno dei principali widget
       *
       * Le dimensioni di Card dipendono dagli elementi interni
       * a meno che non sia inclusa in un Container con la larghezza definita
       */
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10, // Altezza della tastiera virtuale +10
          ),
          child: Column(
            children: <Widget>[
              /*
               * TextField è il widget dell'input di tipo testo
               *
               * Ha numerose proprietà tra le quali:
               *     - la validazione dell'input
               *     - eventi listener (onChanged, onSubmitted ecc...)
               *     - controller (gestisce l'immagazzinamento dell'input in variabili)
               */
              TextField(
                decoration: InputDecoration(labelText: 'Titolo'),
                controller:
                    _titleController, // Salvo in automatico l'input inserito
                // onSubmitted vuole una funzione alla quale dovrei passare una String in input.
                // In questo caso la String non la utilizzo quindi scrivo la funzione anonima
                // scrivendo (_) come parametro.
                onSubmitted: (_) => _submitData(),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Cifra spesa'),
                controller: _amountController,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _submitData(),
              ),
              Container(
                height: 70,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text((_selectedDate == null)
                          ? 'Nessuna data scelta'
                          : 'Data: ${DateFormat.yMd('it_IT').format(_selectedDate)}'),
                    ),
                    AdaptiveFlatButton('Inserisci Data', _presentDatePicker),
                  ],
                ),
              ),
              RaisedButton(
                child: Text('Aggiungi'),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).textTheme.button.color,
                onPressed: _submitData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
