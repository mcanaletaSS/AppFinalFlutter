import 'package:flutter/material.dart';
import 'package:saleschat/pages/notfound_page.dart';
import 'package:saleschat/routes/routes.dart';
 
void main() => runApp(MyApp());
 
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SalesChat',
      navigatorKey: navigatorKey,
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      routes: getApplicationRoutes(),
      onGenerateRoute: (RouteSettings settings){
        return MaterialPageRoute(
          builder: (context) => NotFoundPage()
        );
      },
    );
  }
}