import 'package:flutter/material.dart';


/*
 * Widget per i bottoni delle risposte del form
 */
class Risposta extends StatelessWidget {
  /*
   * Questa proprietà conserva un puntatore ad una funzione passata in input al costruttore
   * la funzione gestisciRisposta() è un placeholder di quella presente in main.dart.
   * La funzione principale gestirà quello che effettivamente deve succedere quando si preme
   * sul bottone. Non posso e non devo saperlo in questo file ma in quello principale...
   *
   * Le proprietà sono final e non const perché alla creazione della classe non possiamo ancora popolarle,
   * una volta invocato il costruttore, si popolano le proprietà e queste diventano immodificabili.
   * Quindi una volta popolate diventano come le proprietà const!
   * Una variabile const, infatti, non può mai cambiare il proprio valore...
   */
  final Function gestisciRisposta;
  final String testoRisposta;

  /*
   * Costruttore
   */
  Risposta(this.gestisciRisposta, this.testoRisposta);


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: Text(testoRisposta),
        /*
         * Ad onPressed passo il NOME della funzione che deve attivare l'utente
         * Se scrivessi "onPressed: gestisciRisposta()," starei eseguendo la funzione gestisciRisposta()
         * a tempo di compilazione. Quindi passo il "puntatore" alla funzione!
         */
        onPressed: gestisciRisposta,
      ),
    );
  }
}
