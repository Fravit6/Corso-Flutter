const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
// Qui inserisco le funzioni server di Firebase

// Trigger per la creazione di un nuovo messaggio
// (in pratica qualsiasi documento in chat/xxx)
exports.myFunction = functions.firestore
    .document("chat/{message}")
    .onCreate((snap, context) => {
      return admin.messaging().sendToTopic("chat", {
        notification: {
          title: snap.data().username,
          body: snap.data().text,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
    });
