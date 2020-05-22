import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:saleschat/providers/http_provider.dart';
import 'package:saleschat/providers/preferences_provider.dart';

class ExportPage extends StatefulWidget {
  ExportPage({Key key}) : super(key: key);

  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exportar contacte'),
      ),
      body: FutureBuilder(
        future: _getUserQR(),
        builder: (BuildContext context, AsyncSnapshot<Column> snapshot){
          if(snapshot.hasData) return Center(child: snapshot.data);
          return Center(child: CircularProgressIndicator());
        }
      ),
    );
  }

  Future<Column> _getUserQR() async {
    String phone = await sharedPreferencesProvider.getStringValue('phone');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Escaneja el codi:', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
        SizedBox(height: 50),
        QrImage(
          data: phone,
          version: QrVersions.auto,
          size: 250,
          foregroundColor: Colors.red,
          errorStateBuilder: (cxt, err) {
            return Container(
              child: Center(
                child: Text(
                  "Vaja! Alguna cosa ha fallat...",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}