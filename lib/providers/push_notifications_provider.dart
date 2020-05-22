import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:saleschat/providers/messages_provider.dart';
import 'package:saleschat/providers/preferences_provider.dart';

class PushNotificationProvider {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  initNotifications() async {
    _firebaseMessaging.requestNotificationPermissions();
    String token = await _firebaseMessaging.getToken();
    await sharedPreferencesProvider.setStringValue('pushNotificationToken', token);


    _firebaseMessaging.configure(
      onLaunch: (info) async {
        await MessagesProvider().afegirMissatge(info['data']['message'], info['data']['userID'], 0);
      },
      onMessage: (info) async {
        await MessagesProvider().afegirMissatge(info['data']['message'], info['data']['userID'], 0);
      },
      onResume: (info) async {
        await MessagesProvider().afegirMissatge(info['data']['message'], info['data']['userID'], 0);
      },
      onBackgroundMessage: myBackgroundMessageHandler
    );
  }



  static Future<void> myBackgroundMessageHandler(Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      await MessagesProvider().afegirMissatge(message['data']['message'], message['data']['userID'], 0);
    }
  }
}