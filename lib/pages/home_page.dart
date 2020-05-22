import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _flutterLogo(),
            _whiteSpace(50),
            _crearNouUsuari(),
            _whiteSpace(20),
            _iniciarSessio()
          ],
        ),
      ),
    );
  }

  Widget _flutterLogo(){
    return FlutterLogo(
      colors: Colors.red,
      size: 150,
    );
  }

  Widget _crearNouUsuari(){
    return RaisedButton(
      padding: EdgeInsets.only(left: 50, right: 50, top: 20, bottom: 20),
      child: Text(
        'Crear nou usuari',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20
        ),
      ),
      color: Colors.red,
      onPressed: (){
        Navigator.pushNamed(context, 'verifyPhone');
      }
    );
  }

  Widget _iniciarSessio(){
    return OutlineButton(
      borderSide: BorderSide(
        color: Colors.red,
        width: 2
      ),
      child: Text(
        'Iniciar sessió',
        style: TextStyle(
          color: Colors.red,
          fontSize: 15
        ),
      ),
      onPressed: (){
        Navigator.pushNamed(context, 'login');
      }
    );
  }

  Widget _whiteSpace(double space){
    return SizedBox(
      height: space,
    );
  }
}