import 'package:flutter/foundation.dart'; // Mi permette di usare le funzioni di flutter (@required)

/*
 * Oggetto Transaction
 */
class Transaction {
  final String id; // Non deve essere modificata dopo l'inizializzazione
  String title;
  double amount;
  DateTime date;

  // Costruttore con parametri by name
  Transaction({
    @required this.id,
    @required this.title,
    @required this.amount,
    @required this.date,
  });
}
