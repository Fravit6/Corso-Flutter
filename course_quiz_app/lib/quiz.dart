import 'package:flutter/material.dart';

import './domanda.dart';
import './risposta.dart';

/*
 * Widget che gestisce il quiz dell'app
 */
class Quiz extends StatelessWidget {
  final List<Map<String, Object>> datiForm;
  final int indiceDomanda;
  final Function gestoreSubmitForm;

  /*
   * Passo i parametri al costruttore per nome
   * in questo modo sarebbero opzionali ma con il decorator @required non lo sono più
   */
  Quiz({
    @required this.gestoreSubmitForm,
    @required this.indiceDomanda,
    @required this.datiForm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Qui chiamo un widget esterno (domanda.dart) invocandone il costruttore
        Domanda(datiForm[indiceDomanda]['testoDomanda']),
        /*
         * Qua so cazzi...
         * Creo una lista di widget con toList()
         * questa lista è formata dai vari output della classe Risposta() quindi sono widget (bottoni)
         *
         * Ad ogni elemento della lista, quindi ad ogni bottone, passo la funzione per la gestione della risposta
         * (la funzione listner del bottone) e il testo del bottone.
         * Il listner del bottone non può avere parametri ma la mia funzione compilaForm() necessita del punteggio della risposta,
         * quindi wrappo la funzione compilaForm in una funzione anonima di una riga " () => "
         *
         * Per prelevare correttamente il testo del bottone scorro la lista di "risposte" presente nella lista "datiForm"
         * e per ogni valore presente nella lista interna creo un widget bottone
         *
         * La funzione map() esegue una funzione su ogni elemento sulla quale la si esegue (come un for each),
         * il passaggio di parametri avviene per copia (non si modifica la lista passatagli).
         *
         * In questo caso passo a map() una funzione anonima che ha come parametro risposta.
         * Devo eseguire una sorta di cast a List<Map<String, Object>> per permettere lo svolgimento di map() senza problemi
         * (anche se datiForm[_indiceDomanda]['risposte'] è effettivamente una List)
         *
         * Alla fine passo tutto a toList() che genera la lista di widget!
         *
         * Questa lista appena generata deve essere inserita insieme altri widget presenti qui,
         * gli altri widget, infatti, erano già figli di una lista. Devo convertire la lista creata dal toList()
         * in children della lista esterna, uso l'operatore spread "..." per fare ciò
         *
         */
        ...(datiForm[indiceDomanda]['risposte'] as List<Map<String, Object>>)
            .map((risposta) {
          return Risposta(() => gestoreSubmitForm(risposta['score']), risposta['text']);
        }).toList(),
      ],
    );
  }
}
