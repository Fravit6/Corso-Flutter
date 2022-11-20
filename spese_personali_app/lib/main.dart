import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './widgets/chart.dart';
import './models/transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';

void main() {
  /*
   * SystemChrome è la classe che mi permette di gestire le impostazioni generali dell'app
   *
   * In questo caso disabilito la modalità landscape
   */
  /*WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);*/
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spese personali',
      theme: ThemeData(
          primarySwatch:
              Colors.purple, // Genera anche le sfumature del principale
          accentColor: Colors.amber,
          errorColor: Colors.red,
          fontFamily: 'Quicksand',
          // Sovrascrivo lo stile dei titoli
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                button: TextStyle(
                  color: Colors.white,
                ),
              ),
          appBarTheme: AppBarTheme(
            // Sovrascrivo lo stile dell'AppBar con le mie direttive
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          )),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Questa proprietà è definita final ma posso modificarne il contenuto a mio piacimento ( vedi _addNewTransaction() )
  // Se avessi voluto una proprietà non modificabile avrei dovuto avere:
  // final List<Transaction> _userTransactions = final [];
  // In questo modo oltre al puntatore avrei avuto final anche il contenuto
  final List<Transaction> _userTransactions = [
    Transaction(
      id: 't1',
      title: 'Nuove scarpe',
      amount: 99.99,
      date: DateTime.now(),
    ),
    Transaction(
        id: 't2',
        title: 'Spesa Settimanale',
        amount: 16.53,
        date: DateTime.now()),
  ];

  bool _showChart = false;

  /*
   * Getter
   * (Un getter equivale ad una proprietà ottenuta dinamicamente alla chiamata)
   *
   * Restituisco una nuova lista con le transazioni degli ultimi 7 giorni
   */
  List<Transaction> get _recentTransaction {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }




  /*
   * Aggiunge una nuova transaction
   */
  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }



  /*
   * Mostra pannello in evidenza sulla schermata con il form di aggiunta di una transaction
   * ( dal pulsante FloatingActionButton() )
   */
  void _startAddNewTransaction(BuildContext ctx) {
    /*
     * Funzione di Flutter per mostrare il pannello in basso
     * Chiede in input il context dell'app e un builder
     * Il builder deve avere come parametro un altro context e restituisce i widget che devono essere inclusi nel pannello
     *
     * In questo caso il widget è gestito all'esterno, gli passo infatti il puntatore della funzione come parametro
     *
     * GestureDetector è il widget che controlla i tap dell'utente, lo utilizzo per agganciare una funzione
     * che non esegue nulla al tap dell'utente (in questo modo non si chiude il pannello al click dell'utente)
     */
    showModalBottomSheet(
      context: ctx,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }



  /*
   * Elimina una transaction dalla lista
   */
  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }


  /*
   * context è un insieme di meta informazioni sul widget in questione e su tutti gli altri!
   * è diverso per ogni widget ma è strettamente legato agli altri
   *
   * Dato un context posso avere info sugli altri widget perché Flutter costruisce uno skeleton di context
   * che ha la stessa struttura dell'albero dei widget
   */
  @override
  Widget build(BuildContext context) {
    // MediaQuery è una classe che mi permette di avere info sul dispositivo (e sul suo schermo)
    // Salvo in una variabile le proprietà MediaQuery così da non doverle caricare ad ogni utilizzo
    final mediaQuery = MediaQuery.of(context);

    // Salvo in una variabile l'orientamento del dispositivo
    final isLandscape = mediaQuery.orientation == Orientation.landscape;




    // Salvo il widget AppBar in una variabile così calcolo le sue proprietà (come l'altezza)
    // Ne creo una versione iOS e una Android
    // Da notare che la libreria Cupertino non ha IconButton()
    final PreferredSizeWidget appBarWidget = Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text('Spese personali'),
            trailing: Row(
              // La riga occupa il minimo spazio possibile (di default è il max)
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          )
        : AppBar(
            title: Text('Spese personali'),
            // I widget passati ad actions sono disposti automaticamente nella AppBar
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              )
            ],
          );




    // Salvo il widget della lista di transaction
    final transactionListWidget = Container(
      height: (mediaQuery.size.height -
              appBarWidget.preferredSize.height -
              mediaQuery.padding.top) * 0.75,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );




    /*
     * SafeArea limita lo spazio della mia app alle zone consentite
     * (ad esempio l'iPhone X ha la zona centrale della fotocamera)
     */
    final bodyWidget = SafeArea(
      /*
       * SingleChildScrollView è il widget che gestisce lo scrolling del contenuto
       *
       * Deve essere contenuto in un widget con altezza fissa!  Altrimenti lo scrolling non riesce a calcolare le misure
       * (in questo caso il padre è direttamente lo Scaffold, funziona perché il device ha altezza nota)
       */
      child: SingleChildScrollView(
        /*
       * Column gestisce i widget children verticalmente
       *
       * Così come Row, Column non ha la proprietà decorator, possiamo solo definire gli allineamenti interni
       *
       * Le dimensioni di Column e Row sono il massimo possibile rispetto al padre
       *
       * Di default tutti i children sono allineati in alto in verticale
       * Di default un child più stretto è allineato al centro della colonna in orizzontale
       *
       * mainAxisAlignment gestisce l'allineamento lungo l'asse centrale (per le Column è quello verticale)
       * crossAxisAlignment gestisce il secondario
       */
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Se il device è in verticale:
            // mostro il grafico e la lista delle transazioni

            // Se il device è in orizzontale (isLandscape == true):
            // mostro la checkbox, e uno tra il grafico oppure la lista con le transazioni
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Mostra Grafico: ', style: Theme.of(context).textTheme.headline6,),
                  Switch.adaptive(
                    activeColor: Theme.of(context).primaryColor,
                    value: _showChart,
                    onChanged: (newVal) {
                      setState(() {
                        _showChart = newVal;
                      });
                    },
                  ),
                ],
              ),

            if (!isLandscape)
              Container(
                // In questo caso imposto l'altezza del widget come 75vh!
                // (togliendo l'altezza della AppBar e lo spazio sopra l'app per lo schermo curvo)
                height: (mediaQuery.size.height -
                        appBarWidget.preferredSize.height -
                        mediaQuery.padding.top) * 0.3,
                child: Chart(_recentTransaction),
              ),
            if (!isLandscape) transactionListWidget,

            if (isLandscape)
              (_showChart)
                  ? Container(
                      height: (mediaQuery.size.height -
                              appBarWidget.preferredSize.height -
                              mediaQuery.padding.top) * 0.75,
                      child: Chart(_recentTransaction),
                    )
                  : transactionListWidget,
          ],
        ),
      ),
    );

    /*
     * Qui effettivamente costruisco l'app
     */
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: bodyWidget,
            navigationBar: appBarWidget,
          )
        : Scaffold(
            appBar: appBarWidget,
            body: bodyWidget,

            /*
             * Pulsante fixed in basso al centro
             */
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => _startAddNewTransaction(context),
            ),
          );
  }
}
