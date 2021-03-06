import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saleschat/providers/contacts_provider.dart';
import 'package:saleschat/providers/database_provider.dart';
import 'package:saleschat/providers/http_provider.dart';
import 'package:saleschat/providers/preferences_provider.dart';
import 'package:saleschat/providers/storage_provider.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  File _image;
  String _username, _state;
  HttpProvider _httpProvider = new HttpProvider();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child:Scaffold(
        appBar: AppBar(
          title: Text('Nou Usuari'),
          leading: Icon(Icons.person)
        ),
        body: _signInBody(context)
      )
    );
  }

  Widget _signInBody(BuildContext context){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[
            !_loading ? _photoInput(context) : SizedBox(),
            _whiteSpace(),
            !_loading ?_usernameInput() : SizedBox(),
            _whiteSpace(),
            !_loading ? _stateInput() : SizedBox(),
            _whiteSpace(),
            !_loading ? _createButton(context) : SizedBox(),
            _loading ? _loadingWidget() : SizedBox()
          ],
        ),
      ),
    );
  }
  
  Widget _photoInput(BuildContext context){
    return GestureDetector(
      onTap: () {
         showModalBottomSheet(
            context: context,
            builder: (BuildContext context) => _photoOptions(context)
        );
      },
      child: CircleAvatar(
        backgroundImage: _image == null ? AssetImage('assets/user.png') : FileImage(_image),
        backgroundColor: Colors.white,
        radius: 75,
      ),
    );
  }

  Widget _usernameInput(){
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Nom d\'usuari'
      ),
      onChanged: (txt){
        setState(() {
          _username = txt;
        });
      },
    );
  }

  Widget _stateInput(){
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: 'Estat'
      ),
      onChanged: (txt){
        setState(() {
          _state = txt;
        });
      },
    );
  }

  Widget _whiteSpace(){
    return SizedBox(
      height: 35,
    );
  }

  Widget _loadingWidget(){
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _createButton(context){
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      child: Text('Crear Usuari'),
      autofocus: true,
      onPressed: () async {
        setState(() {
          _loading = true;
        });
        await createUser(context);
        setState(() {
          _loading = false;
        });
      }
    );
  }

  Widget _photoOptions(BuildContext context) {
    return Container(
      height: 200,
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Càmera'),
            onTap: () => getImage(context, true)
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Galería'),
            onTap: () => getImage(context, false)
          ),
          _image != null ? ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Eliminar imatge actual'),
            onTap: () => removeImage(context)
          ) : SizedBox()
        ],
      ),
    );
  }

  void getImage(BuildContext context, bool camera) async {
    ImageSource imageSource = camera ? ImageSource.camera : ImageSource.gallery;
    File image = await ImagePicker.pickImage(source: imageSource);
    setState(() => _image = image);
    Navigator.pop(context);
  }

  void removeImage(BuildContext context) {
    setState(() => _image = null);
    Navigator.pop(context);
  }

  Future<void> createUser(BuildContext context) async {
    DatabaseProvider db = DatabaseProvider.instance;
    String _phone = await sharedPreferencesProvider.getStringValue('phone');
    File image = await getImageFileFromAssets('user.png');
    if(_image == null){
      setState(() {
        _image = image;
      });
    }
    String photoUrl = await StorageProvider().postDocument(_image, _phone);
    Response respuesta = await _httpProvider.createUser(
      _phone,
      _state,
      _username,
      photoUrl
    );
    if(respuesta.codigo == 201) {
      List<Map<String, String>> phones = await ContactsProvider().getContactsPhones();
      await HttpProvider().verifyPhones(phones);
      await db.insert(
        {
          'USERID': respuesta.mensaje,
          'PHOTO': photoUrl,
          'STATE': _state,
          'USERNAME': _username,
          'PHONE': _phone,
          'NAME': 'JO',
          'ME': 1
        },
        'CONTACTS'
      );
      Navigator.pushNamed(context, 'chats');
    }else{
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (BuildContext context) {
           return getAlertDialog(respuesta.mensaje);
         },
       );
    }
  }
  
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Widget getAlertDialog(String mensaje){
    return AlertDialog(
      title: Text(
        'Error',
        style: TextStyle(
          fontSize: 20
        ),
      ),
      content: SingleChildScrollView(
        child: Text(mensaje),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'D\'acord',
            style: TextStyle(
              color: Colors.red,
              fontSize: 17
            ),
          ),
          onPressed: () => Navigator.of(context).pop()
        ),
      ],
    );
  }

}