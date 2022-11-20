import 'package:flutter/material.dart';

/*
 * Widget che gestisce l'output del quiz
 */
class Risultato extends StatelessWidget {
  final int totalScore;
  final Function gestoreRestart;

  Risultato(this.totalScore, this.gestoreRestart);

  String get getTotalScore {
    var testoRisultato;
    if (totalScore <= 8) {
      testoRisultato = 'Il tuo punteggio è inferiore ad 8!';
    } else if (totalScore <= 12) {
      testoRisultato = 'Il tuo punteggio è inferiore a 12!';
    } else if (totalScore <= 16) {
      testoRisultato = 'Il tuo punteggio è inferiore a 16!';
    } else {
      testoRisultato = 'Il tuo punteggio è superiore a 16!';
    }

    return testoRisultato;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            getTotalScore,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          FlatButton(
            child: Text('Ricomincia!'),
            textColor: Colors.blue,
            onPressed: gestoreRestart,
          ),
        ],
      ),
    );
  }
}
