import 'package:flutter/material.dart';
import 'package:saleschat/pages/chats_page.dart';
import 'package:saleschat/providers/push_notifications_provider.dart';
import '../providers/preferences_provider.dart';

import 'package:saleschat/pages/home_page.dart';
import 'package:saleschat/pages/notfound_page.dart';

class LoadingPage extends StatefulWidget {
  LoadingPage({Key key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    super.initState();
    final pushProvider = new PushNotificationProvider();
    pushProvider.initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sharedPreferencesProvider.getStringValue('token'),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if(snapshot.hasData){
          if(snapshot.data.length > 0) return ChatsPage();
          return HomePage();
        }else if(snapshot.hasError){
            return NotFoundPage(); 
        }else{
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}