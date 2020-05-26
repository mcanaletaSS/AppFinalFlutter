import 'package:flutter/material.dart';
import 'package:saleschat/pages/chats_page.dart';
import 'package:saleschat/providers/database_provider.dart';
import 'package:saleschat/providers/http_provider.dart';

class ChatPage extends StatefulWidget {
  ChatPage({Key key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Map<String, dynamic> _user; 
  TextEditingController _controller = TextEditingController();
  String _newMessage;
  List<Map<String, dynamic>> _messages;
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    _loadUser();
    return Scaffold(
      appBar: AppBar(
         title: Text(_user['NAME']),
         leading: Padding(
           padding: const EdgeInsets.all(8.0),
           child: CircleAvatar(
            backgroundImage: NetworkImage(_user['PHOTO']),
            backgroundColor: Colors.transparent,
        ),
         ),
      ),
      body: _getBody(context),
    );
  }


  Widget _getBody(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _getMessagesBody(),
        _getNewMessage()
      ],
    );
  }

  Widget _getMessagesBody(){
    return Expanded(
            flex: 1,
            child: FutureBuilder(
              future: _getMessages(),
              builder: (BuildContext contexto, AsyncSnapshot snapshot) {
                  if(snapshot.hasData){
                    _messages = snapshot.data;
                    return ListView(
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      children: _generarLListaMisatges()
                    );
                  }
                  return Center(
                    child: new CircularProgressIndicator()
                  );
              },
            )
          );
  }

  List<Widget> _generarLListaMisatges(){
    List<Widget> opcions = new List<Widget>();
    _messages.forEach((message) {
      bool me = message['ME'] == 0 ? false : true;
      int minute = DateTime.parse(message['DATE']).minute;
      String hora = DateTime.parse(message['DATE']).hour.toString() +
       ':' + (minute < 10 ? '0' : '')+ minute.toString() + 'h';
      Widget opcio =  Row(
        mainAxisAlignment: me ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          new GestureDetector(
            onLongPress: () {
            },
            onTap: () {
            },
            child: new Padding(
              padding: EdgeInsets.only(right: 15, bottom: 4, top:4, left:15),
              child: 
              new DecoratedBox(
                decoration: new BoxDecoration(
                  color: me ? Colors.red[100] : Colors.orange[100],
                  borderRadius: me ? BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)
                  )
                  :
                  BorderRadius.only(
                    bottomRight: Radius.circular(20),
                    topLeft: Radius.circular(20)
                  )
                ),
                child: Column(
                  crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 3),
                      child: SelectableText(message['MESSAGE'],
                      style: TextStyle(
                        color: Colors.black,
                        ),
                      )
                    ),
                    Padding(
                      padding: me ? EdgeInsets.only(bottom: 2, top: 2, right: 5) : EdgeInsets.only(bottom: 2, top: 2, left: 5) ,
                      child: Text(hora,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    )
                  ],
                )
              ),
            )
          )
        ],
      );
      opcions.add(opcio);
    });
    return opcions;
  }

  Widget _getNewMessage(){
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        children:<Widget>[
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(right: 15, left: 15),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.redAccent, width: 1)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.redAccent, width: 2)
                  )
                ),
                onChanged: (value) => _newMessage = value,
              ),
            )
          ),
          Ink(
            decoration: const ShapeDecoration(
              color: Colors.red,
              shape: CircleBorder(),
            ),
            child: _isSending ?
              CircularProgressIndicator()
            : IconButton(
              icon: Icon(Icons.send, color: Colors.white,),
              color: Colors.red,
              onPressed: () => _sendMessage(_newMessage)
            ),
          ),
        ],
      )
    );
  }

  //------------------Functions--------------------------
  void _loadUser(){
    final ChatArguments args = ModalRoute.of(context).settings.arguments;
    setState(() {
      _user = args.user;
    });
  }

  Future<void> _sendMessage(String message) async {
    if(message.trim().length > 0){
      setState(() {
        _controller.clear();
        _controller.clearComposing();
        _isSending = true;
      });
      Response response = await HttpProvider().sendUserMessage(message, _user['USERID']);
      if(response.codigo == 200){
        List<Map<String,dynamic>> messages = await _getMessages();
        setState(() {
          _messages = messages;
          _newMessage = "";
          _isSending = false;
        });
      }
    }
  }

  Future<List<Map<String,dynamic>>> _getMessages() async {
    List<Map<String, dynamic>> messages = await DatabaseProvider.instance.queryWhereOrderDesc('MESSAGES','MESSAGERID',_user['USERID'], 'DATE');
    return messages;
  }

  Future<void> _updateMessages() async {
    List<Map<String,dynamic>> messages = await _getMessages();
    setState(() {
      _messages = messages;
    });
  }
}