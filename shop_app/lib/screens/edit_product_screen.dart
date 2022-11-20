import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

/*
 * Page per la modifica e inserimento dei prodotti (da user_products_screen)
 */
class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // Proprietà per passare il focus ai field
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  // Controller per gestire manualmente l'input dell'URL
  final _imageUrlController = TextEditingController();

  // Salvo le info del form in una variabile globale
  // Così da accedervi anche dall'esterno del widget Form
  final _form = GlobalKey<FormState>();

  // Creo l'oggetto prodotto (vuoto e con id=null)
  Product _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  // Valori iniziali del form
  var _initValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  // Alla creazione della page
  @override
  void initState() {
    // Creo il listner manuale per il field dell'URL della foto
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  // Chiamato dopo il build e dopo initState
  @override
  void didChangeDependencies() {
    // Solo la prima volta
    if (_isInit) {
      // Estraggo l'id del prodotto passato da user_product_item
      final productID = ModalRoute.of(context).settings.arguments as String;

      // Se devo modificare un prodotto ho l'id
      if (productID != null) {
        // Estraggo il prodotto dal Provider
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productID);

        // Cambio i valori di default del form
        _initValue = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          //'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }

    // Mi assicuro di non ripetere alla prossima chiamata
    _isInit = false;
    super.didChangeDependencies();
  }

  // Alla chiusura della page
  @override
  void dispose() {
    // Distruggo il listner
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    // Distruggo i FocusNode e i Controller per evitare un memory leak
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  // Carico la foto dall'URL
  void _updateImageUrl() {
    // Appena il field perde il focus aggiorno la page
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) return;
      setState(() {});
    }
  }

  // Valido e prelevo i dati inseriti dall'utente
  Future<void> _saveForm() async {
    // Triggero tutti i metodi validator dei Field
    final isValid = _form.currentState.validate();
    // Se qualche Field ha restituiro un errore non salvo i valori
    if (!isValid) return;

    // Triggero tutti i metodi onSave dei field
    _form.currentState.save();

    // Faccio partire l'animazione del caricamento in attesa del server
    setState(() {
      _isLoading = true;
    });

    // Se il prodotto ricevuto ha un ID vuol dire che devo modificarlo
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.id, _editedProduct);

    // Altrimenti ne creo uno nuovo
    } else {
      try {
        await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);

      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );

      }
    }

    // Fine dell'animazione
    setState(() {
      _isLoading = false;
    });

    // Alla fine chiudo la page e torno indietro
    Navigator.of(context).pop();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),

      // In caso di attesa del server mostro un loading
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                // Qui salvo i dati del form
                key: _form,

                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValue['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      // Al completamento passo il focus al field del prezzo
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },

                      // Logica di validazione
                      validator: (value) {
                        if (value.isEmpty) return 'Please provide a value.';
                        return null;
                      },

                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: value,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      // Al completamento passo il focus al field della descrizione
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },

                      // Logica di validazione
                      validator: (value) {
                        if (value.isEmpty) return 'Please provide a price.';
                        if (double.tryParse(value) == null)
                          return 'Please enter a valid number';
                        if (double.parse(value) <= 0)
                          return 'Please a number greater than 0.';
                        return null;
                      },

                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(value),
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,

                      // Logica di validazione
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Please provide a description.';
                        if (value.length < 10)
                          return 'Should be at least 10 characters long.';
                        return null;
                      },

                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: value,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),

                        // Questo Field è in una Row
                        // Di default il Field occupa il massimo spazio possibile,
                        // la Row anche, quindi il Field ha larghezza infinita.
                        // Inserisco il field in un Expanded così da avere larghezza fissa...
                        Expanded(
                          child: TextFormField(
                            // Il valore di default deve essere impostato dal controller
                            //initialValue: _initValue['imageUrl'],
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            // Voglio effettuare controlli prima del submit
                            // Gestisco quest'input manualmente con un Controller
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,

                            // Logica di validazione
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please provide an image URL.';
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https'))
                                return 'Please enter a valid URL.';
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg'))
                                return 'Please enter a valid image URL.';
                              return null;
                            },

                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },

                            // Alla fine faccio il submit
                            onFieldSubmitted: (value) => _saveForm(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
