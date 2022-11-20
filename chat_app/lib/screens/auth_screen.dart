import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/auth/auth_form.dart';

/*
 * Page con il form per il login o registrazione
 */
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;

  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    var authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Creo un documento nello storage di Firebase
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(_auth.currentUser.uid + '.jpg');
        // Carico la foto nel documento appena creato
        await ref.putFile(image);
        // Ottengo il link pubblico alla foto
        final url = await ref.getDownloadURL();


        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': url,
        });

        print('Finita la registrazione');
      }
    } on FirebaseAuthException catch (error) {
      var message = "An error occurred, please check your credentials!";
      if (error.message != null) message = error.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
