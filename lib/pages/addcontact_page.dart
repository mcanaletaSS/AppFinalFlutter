import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:saleschat/providers/http_provider.dart';

class AddContactPage extends StatefulWidget {
  AddContactPage({Key key}) : super(key: key);

  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  String _name, _phone;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text('Afegir contacte'),
         actions: <Widget>[
           _phone != null ? IconButton(
             icon: Icon(Icons.cancel),
             onPressed: (){
               setState(() {
                 _phone = null;
                 _name = null;
               });
             }
            ) : SizedBox()
         ],
       ),
       body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _phone == null ? Text('Fes clic per capturar el codi') : SizedBox(),
              _phone == null ? RaisedButton(
                child: Text('Capturar QR'),
                onPressed: () async {
                  _getUser(context);
                },
              ) : SizedBox(),
              _phone != null && !_isLoading ? Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Nom del contacte',
                    labelStyle: TextStyle(
                      fontSize: 20
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Icon(
                        Icons.text_fields,
                        size: 30,
                      ),
                    )
                  ),
                  style: TextStyle(
                    fontSize: 30,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _name = val;
                    });
                  },
                ),
              ) : SizedBox(),
              _phone != null && !_isLoading ? Padding(
                padding: EdgeInsets.only(left: 25.0, right: 25.0),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 100.0),
                  child: OutlineButton(
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 2
                    ),
                    child: Center(
                      child: Text('Guardar', style: TextStyle(color: Colors.red)),
                    ),
                    onPressed: () {
                      _saveContact(context);
                    }
                  ),
                ),
              ) : SizedBox(),
              _phone != null && _isLoading ? CircularProgressIndicator() : SizedBox()
            ],
          ), 
       )
    );
  }
  Future<void> _getUser(BuildContext context) async {
    ScanResult result = await BarcodeScanner.scan();
    if(result.type == ResultType.Barcode){
      setState(() {
        _phone = result.rawContent;
      });
    }else if(result.type != ResultType.Cancelled){
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
          ),
          title: Row(
            children: <Widget>[
              Icon(Icons.error_outline, color: Colors.red,),
              SizedBox(width: 10),
              Text('Error', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Sembla que hi ha hagut algun error. Sisuplau, torna a intentar-ho en uns minuts',
                textAlign: TextAlign.center,
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'D\'acord',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20
                ),
              )
            )
          ],        
        )
      );
    }
  }

  Future<void> _saveContact(context) async {
    setState(() {
      _isLoading = true;
    });
    await HttpProvider().verifyPhones([{
      'phone': _phone,
      'name': _name
    }]);
    setState(() {
      _isLoading = false;
      Navigator.of(context).pop();
    });
  }
}