import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saleschat/providers/database_provider.dart';
import 'package:saleschat/providers/http_provider.dart';
import 'package:saleschat/providers/preferences_provider.dart';
import 'package:saleschat/providers/storage_provider.dart';

class UpdatePage extends StatefulWidget {
  UpdatePage({Key key}) : super(key: key);

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  File _image;
  String _imgUrl;
  String _username, _state;
  HttpProvider _httpProvider = new HttpProvider();
  bool _loading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Usuari'),
      ),
      body: FutureBuilder(
        future: _getUser(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData){
            return _updateBody(context);
          }else{
            return Center(child: CircularProgressIndicator());
          }
        }
      )
    );
  }

  Widget _updateBody(BuildContext context){
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
            !_loading ? _updateButton(context) : SizedBox(),
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
        backgroundImage: _image == null ? NetworkImage(_imgUrl) : FileImage(_image),
        backgroundColor: Colors.redAccent,
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
      initialValue: _username,
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
      initialValue: _state,
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

  Widget _updateButton(context){
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      child: Text('Actualitzar Usuari'),
      autofocus: true,
      onPressed: () async {
        setState(() {
          _loading = true;
        });
        await updateUser(context);
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
            title: Text('Eliminar canvi'),
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
  
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Widget getAlertDialog(String mensaje, bool isError){
    return AlertDialog(
      title: Text(
        isError ? 'Error' : 'Actualitzat!',
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

  Future<void> updateUser(BuildContext context) async {
    DatabaseProvider db = DatabaseProvider.instance;
    String _phone = await sharedPreferencesProvider.getStringValue('phone');
    if(_image == null){
      File image = await getImageFileFromAssets('user.png');
      setState(() {
        _image = image;
      });
    }
    String photoUrl = await StorageProvider().postDocument(_image, _phone);
    Response respuesta = await _httpProvider.updateUser(
      _phone,
      _state,
      _username,
      photoUrl
    );
    if(respuesta.codigo == 200) {
      await db.updateWhere(
        {
          'USERID': respuesta.mensaje,
          'PHOTO': photoUrl,
          'STATE': _state,
          'USERNAME': _username,
          'PHONE': _phone,
          'NAME': 'JO',
          'ME': 1
        },
        'CONTACTS', 'NAME', 'JO'
      );
      showDialog(
         context: context,
         barrierDismissible: false,
         builder: (BuildContext context) {
           return getAlertDialog('Dades actualitzades correctament.', false);
         },
       );
    }else{
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (BuildContext context) {
           return getAlertDialog(respuesta.mensaje, true);
         },
       );
    }
  }

  Future<bool> _getUser() async {
    DatabaseProvider db = DatabaseProvider.instance;
    List<Map<String, dynamic>> result = await db.queryWhere('CONTACTS', 'NAME', 'JO');
    if(result.length > 0 && _imgUrl == null && _username == null && _state == null){
      setState(() {
        _imgUrl = result[0]['PHOTO'];
        _state = result[0]['STATE'];
        _username = result[0]['USERNAME'];
      });
    }
    return true;
  }

}