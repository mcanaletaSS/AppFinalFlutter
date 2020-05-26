import 'package:flutter/material.dart';
import 'package:saleschat/pages/configs_page.dart';

import 'package:saleschat/pages/home_page.dart';
import 'package:saleschat/pages/chats_page.dart';
import 'package:saleschat/pages/chat_page.dart';
import 'package:saleschat/pages/loading_page.dart';
import 'package:saleschat/pages/login_page.dart';
import 'package:saleschat/pages/notfound_page.dart';
import 'package:saleschat/pages/signin_page.dart';
import 'package:saleschat/pages/export_page.dart';
import 'package:saleschat/pages/addcontact_page.dart';
import 'package:saleschat/pages/update_page.dart';
import 'package:saleschat/pages/verifyphone_page.dart';

Map<String, WidgetBuilder> getApplicationRoutes(){
  return <String, WidgetBuilder>{
    '/': (BuildContext context) => LoadingPage(),
    'home': (BuildContext context) => HomePage(),
    'signin': (BuildContext context) => SignInPage(),
    'login': (BuildContext context) => LoginPage(),
    'chats': (BuildContext context) => ChatsPage(),
    'chat': (BuildContext context) => ChatPage(),
    'configs': (BuildContext context) => ConfigsPage(),
    'verifyPhone': (BuildContext context) => VerifyPhonePage(),
    'export': (BuildContext context) => ExportPage(),
    'addContact': (BuildContext context) => AddContactPage(),
    'updateProfile': (BuildContext context) => UpdatePage(),
    'notFound': (BuildContext context) => NotFoundPage(),
  };
}