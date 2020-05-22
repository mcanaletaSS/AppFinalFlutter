import 'package:saleschat/bloc/chats_bloc.dart';
import 'package:saleschat/providers/database_provider.dart';

class MessagesProvider {
  final chatsbloc = ChatsBloc();
  Future<void> afegirMissatge(String misatge, String userId, int me) async {
    String date = new DateTime.now().toIso8601String();
    DatabaseProvider db = DatabaseProvider.instance;
    int count = await db.queryWhereCount('CHATS', 'USERID', userId);
    if(count == 0){
      await chatsbloc.createChat(userId);
    }
    await db.insert({
      'MESSAGERID': userId,
      'MESSAGE': misatge,
      'DATE': date,
      'ME': me
    }, 'MESSAGES');
  }
}