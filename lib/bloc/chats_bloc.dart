import 'dart:async';

import 'package:saleschat/providers/database_provider.dart';

class ChatsBloc {
  DatabaseProvider db = DatabaseProvider.instance;

   ChatsBloc() {
    getChats();
  }
  final _chatsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get chats => _chatsController.stream;
  

  dispose() {
    _chatsController.close();
  }

  Future<void> getChats() async {
    db.queryJoin('CHATS', 'CONTACTS', 'USERID', 'USERID').then((value){
      _chatsController.sink.add(value);
    });
  }

  Future<void> createChat(String userId) async {
    await db.insert({'USERID': userId}, 'CHATS');
    await getChats();
  }
}