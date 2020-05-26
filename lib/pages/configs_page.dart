import 'package:flutter/material.dart';

class ConfigsPage extends StatefulWidget {
  ConfigsPage({Key key}) : super(key: key);

  @override
  _ConfigsPageState createState() => _ConfigsPageState();
}

class _ConfigsPageState extends State<ConfigsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text('Configuracions'),
       ),
       body: ListView(
         children: _opcions(context),
       ),
    );
  }

  List<Widget> _opcions(BuildContext context) {
    List<Widget> opcions = new List<Widget>();
    Widget opcio = Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.account_box, size: 30,),
          title: Text('Editar perfil', style: TextStyle(fontSize: 20),),
          onTap: () => Navigator.of(context).pushNamed('updateProfile'),
          contentPadding: EdgeInsets.only(left: 15, top: 10, bottom: 5),
        ),
        Divider()
      ]
    );
    opcions.add(opcio);
    return opcions;
  }

}