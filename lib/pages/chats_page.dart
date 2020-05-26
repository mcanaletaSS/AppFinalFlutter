import 'package:flutter/material.dart';
import 'package:saleschat/bloc/chats_bloc.dart';
import 'package:saleschat/providers/contacts_provider.dart';
import 'package:saleschat/providers/database_provider.dart';
import 'package:saleschat/providers/http_provider.dart';

class ChatsPage extends StatefulWidget {
  ChatsPage({Key key}) : super(key: key);
  final chatsBloc = ChatsBloc();
  

  @override
  _ChatsPageState createState() => _ChatsPageState(this.chatsBloc);
}

class _ChatsPageState extends State<ChatsPage> {
  _ChatsPageState(ChatsBloc chatsBloc){
    this._chatsBloc = chatsBloc;
  }
  ChatsBloc _chatsBloc;
  DatabaseProvider databaseProvider = DatabaseProvider.instance;
  List<Map<String, dynamic>> _contacts = new List<Map<String, dynamic>>();
  List<Map<String, dynamic>> _chats = new List<Map<String, dynamic>>();
  int _active = 0;
  bool _loadingContacts = false;

  @override
  void dispose() {
    super.dispose();
    _chatsBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        initialIndex: _active,
        length: 2,
        child: Scaffold(
          appBar: _appBar(context),
          body: _body(context),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _chatsBloc.getChats(),
            child: Icon(Icons.refresh),
          ),
        )
      )
    );
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      leading: Icon(Icons.inbox),
      title: Text('SalesChat'),
      centerTitle: true,
      actions: <Widget>[
        PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              child: Container(
                width: 160,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.build, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Configuració'),
                  ],
                ),
              ),
              value: 'config',
            ),
            _active == 1 ? PopupMenuItem(
              child: Container(
                width: 160,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.import_export, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Importar'),
                  ],
                ),
              ),
              value: 'import',
            ) : null,
            _active == 1 ? PopupMenuItem(
              child: Container(
                width: 160,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.nfc, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Generar QR'),
                  ],
                ),
              ),
              value: 'export',
            ) : null,
            _active == 1 ? PopupMenuItem(
              child: Container(
                width: 160,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.person_add, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Afegir contacte'),
                  ],
                ),
              ),
              value: 'add',
            ) : null
          ],
          onSelected: (String value){
            if(value == 'config') Navigator.of(context).pushNamed('configs');
            if(value == 'import') _updateNewContacts();
            if(value == 'export') Navigator.of(context).pushNamed('export');
            if(value == 'add') Navigator.of(context).pushNamed('addContact');
          },
        )
      ],
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.chat), text: 'Converses'),
          Tab(icon: Icon(Icons.assignment_ind), text: 'Contactes')
        ],
        onTap: (index){
          setState(() {
            _active = index;
          });
        },
      ),
    );
  }
  Widget _body(BuildContext context){
    return TabBarView(
      children: [
        _llistaChats(context),
        _llistaContactes(context)
      ]
    );
  }

  Widget _loading(bool isContacts) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          isContacts ? Text('Important contactes...') : SizedBox(),
          isContacts ? SizedBox(height: 30) : SizedBox(),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void _openChat(BuildContext context, Map<String, dynamic> user, bool isGroup){
    Navigator.of(context).pushNamed(
      'chat',
      arguments: ChatArguments(user)
    );
  }

  //-----------------------CHATS-----------------------------

  Widget _llistaChats(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatsBloc.chats,
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        snapshot.hasData ? _chats = snapshot.data : null;
        print(snapshot.data);
        if(_chats.length > 0) {
          return RefreshIndicator(
              child: ListView(
                children: _generadorLlistaChats()
              ),
              onRefresh: _updateChats
            );
        }else{
            return _noChatsFound();
        }
      }
    );
  }

  List<Widget> _generadorLlistaChats() {
    final List<Widget> opciones = [];
    _chats.forEach((chats) {
      Widget opcio = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: (){
              _openChat(context, chats, false);
            },
            child:ListTile(
              leading: CircleAvatar(
                radius: 25.0,
                backgroundImage: NetworkImage(chats['PHOTO']),
                backgroundColor: Colors.transparent,
              ),
              title: Text(
                chats['NAME'],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17
                ),
              ),
              subtitle: Text(chats['STATE']),
            ),
          ),
          Divider()
        ],
      );
      opciones.add(opcio);
     });
    return opciones;
  }

  Future<void> _updateChats() async {
    await ChatsBloc().getChats();
  }

  Widget _noChatsFound() {
    return Center(
      child: Text('No tens chats'),
    );
  }

  //--------------FI CHATS----------------------


  //---------------CONTACTES------------------------
  
  Widget _llistaContactes(BuildContext context) {
    return FutureBuilder(
      future: _getContactes(),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if(snapshot.hasData) {
          _contacts = snapshot.data;
          if(_loadingContacts) return _loading(true);
          if(_contacts.length > 0) return RefreshIndicator(
            child: ListView(
              children: _generadorLlistaContactes()
            ),
            onRefresh: _updateContacts
          );
          return _noContactsFound();
        }
        return _loading(false);
      }
    );
  }

  List<Widget> _generadorLlistaContactes() {
    final List<Widget> opciones = [];
    _contacts.forEach((contacte) {
      Widget opcio = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: (){
              _openChat(context, contacte, false);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(contacte['PHOTO']),
                backgroundColor: Colors.transparent,
                radius: 25,
              ),
              title: Text(
                contacte['NAME'],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17
                ),
              ),
              subtitle: Text(contacte['STATE'])
            ),
          ),
          Divider()
        ],
      );
      opciones.add(opcio);
     });
    return opciones;
  }

  Widget _noContactsFound() {
    return Center(
      child: Text('No tens contactes'),
    );
  }

  Future<List<Map<String, dynamic>>> _getContactes() async {
    List<Map<String, dynamic>> contacts = await DatabaseProvider.instance.queryAllRows('CONTACTS');
    return contacts;
  }

  Future<void> _updateContacts() async {
    List<Map<String, dynamic>> contacts = await _getContactes();
    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _updateNewContacts() async {
    setState(() {
      _loadingContacts = true;
    });
    List<Map<String, String>> phones = await ContactsProvider().getContactsPhones();
    await HttpProvider().verifyPhones(phones);
    List<Map<String, dynamic>> contacts = await _getContactes();
    setState(() {
      _loadingContacts = false;
      _contacts = contacts;
    });
  }

  //-------------------FI CONTACTES ---------------------------------
}
class ChatArguments {
  final Map<String, dynamic> user;

  ChatArguments(this.user);
}