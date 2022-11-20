import 'package:flutter/material.dart';

import './quiz.dart';
import './risultato.dart';

void main() {
  runApp(MyApp());
}

/*
 * Questo è il widget padre di tutti
 *
 * E' un widget Stateful, alla chiamata si esegue createState() che chiama a sua volta
 * la classe persistente collegata
 */
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

/*
 * Questa è la classe persistente di MyApp(), infatti, estende State<MyApp>
 * Le sue proprietà non sono legate a quelle di MyApp()
 *
 * Il carattere "_" indica che questa classe è privata (utilizzabile solo in questo file)
 */
class _MyAppState extends State<MyApp> {
  /*
   * Inserendo le proprietà qui mi assicuro che non vengano modificate con ogni build()
   * Attenzione: Le seguenti proprietà possono essere modificate in sicurezza perché MyAppState
   * estende una classe Stateful quindi abbiamo la consistenza con le varie build()
   *
   * Il carattere "_" indica che questa proprietà è privata (utilizzabile solo in questa classe)
   */
  var _indiceDomanda = 0;
  var _totalScore = 0;

  /*
     * Questa è una map che contiene informazioni schematizzate come chiave-valore
     * è qualificata come const perché non deve cambiare i propri valori dopo la compilazione!
     */
  static const _datiForm = [
    {
      'testoDomanda': 'Qual è il tuo colore preferito?',
      'risposte': [
        {'text': 'Nero', 'score': 10},
        {'text': 'Rosso', 'score': 5},
        {'text': 'Verde', 'score': 3},
        {'text': 'Bianco', 'score': 1}
      ]
    },
    {
      'testoDomanda': 'Qual è il tuo animale preferito?',
      'risposte': [
        {'text': 'Scimmia', 'score': 3},
        {'text': 'Alce', 'score': 10},
        {'text': 'Gufo', 'score': 5},
        {'text': 'Squalo', 'score': 9}
      ]
    },
    {
      'testoDomanda': 'Chi è il tuo vip preferito?',
      'risposte': [
        {'text': 'Max', 'score': 6},
        {'text': 'Gianni', 'score': 2},
        {'text': 'Francesco', 'score': 10},
        {'text': 'Carlo', 'score': 1}
      ]
    },
  ];

  /*
   * La funzione setState() forza il ri-rendering del widget per il quale è stato chiamato
   */
  void _compilaForm(int score) {
    _totalScore += score;
    setState(() {
      _indiceDomanda = _indiceDomanda + 1;
    });
    //print(_indiceDomanda);
  }

  void _restartQuiz() {
    setState(() {
      _indiceDomanda = 0;
      _totalScore = 0;
    });
  }

  // @override vuol dire che stiamo sovrascrivendo il metodo ereditato da StatelessWidget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Scaffold è il widget che contiene la pagina
      home: Scaffold(
        // AppBar è il widget che gestisce l'header
        appBar: AppBar(
          title: Text('La mia prima App'),
        ),
        body: (_indiceDomanda < _datiForm.length)
            ? Quiz(
                gestoreSubmitForm: _compilaForm,
                indiceDomanda: _indiceDomanda,
                datiForm: _datiForm)
            : Risultato(_totalScore, _restartQuiz),
      ),
    );
  }
}
