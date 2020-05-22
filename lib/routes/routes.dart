import 'package:flutter/material.dart';

import 'package:saleschat/pages/home_page.dart';
import 'package:saleschat/pages/chats_page.dart';
import 'package:saleschat/pages/chat_page.dart';
import 'package:saleschat/pages/loading_page.dart';
import 'package:saleschat/pages/login_page.dart';
import 'package:saleschat/pages/notfound_page.dart';
import 'package:saleschat/pages/signin_page.dart';
import 'package:saleschat/pages/export_page.dart';
import 'package:saleschat/pages/addcontact_page.dart';
import 'package:saleschat/pages/verifyphone_page.dart';

Map<String, WidgetBuilder> getApplicationRoutes(){
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => LoadingPage(),
    'home': (BuildContext context) => HomePage(),
    'signin': (BuildContext context) => SignInPage(),
    'login': (BuildContext context) => LoginPage(),
    'chats': (BuildContext context) => ChatsPage(),
    'chat': (BuildContext context) => ChatPage(),
    'verifyPhone': (BuildContext context) => VerifyPhonePage(),
    'export': (BuildContext context) => ExportPage(),
    'addContact': (BuildContext context) => AddContactPage(),
    'notFound': (BuildContext context) => NotFoundPage(),
  };
}