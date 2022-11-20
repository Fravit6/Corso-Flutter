import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './message_bubble.dart';

/*
 * Widget che mostra una lista di messaggi
 */
class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser.uid;

    // Snapshots restituisce uno stream di dati che in automatico
    // rimane in ascolto sul db, lo utilizzo per creare i widget contenuti in
    // StreamBuilder che sfrutta questo stream per aggiornare l'albero
    // dei widget in automatico
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final chatDocs = chatSnapshot.data.docs;
          return ListView.builder(
            reverse: true,
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) => MessageBubble(
              chatDocs[index]['text'],
              chatDocs[index]['username'],
              chatDocs[index]['userImage'],
              (chatDocs[index]['userId'] == userId) ? true : false,
              key: ValueKey(chatDocs[index].id),
            ),
          );
        });
  }
}
