import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:saleschat/providers/contacts_provider.dart';
import 'package:saleschat/providers/database_provider.dart';
import 'package:saleschat/providers/messages_provider.dart';
import 'package:saleschat/providers/preferences_provider.dart';
import 'package:saleschat/providers/storage_provider.dart';

class HttpProvider {
  final uri = "saleschatappapi.azurewebsites.net";
  
  DatabaseProvider databaseProvider = DatabaseProvider.instance;

  Future<Response> createUser(String phone, String state, String username, String photoUrl) async {
    Response devolver = new Response();
    String pushNotificationToken;
    pushNotificationToken = await sharedPreferencesProvider.getStringValue('pushNotificationToken');
     
    http.Response response = await http.post(
      new Uri.http(uri, '/user/' + phone),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'pushServiceToken': pushNotificationToken,
        'photo': photoUrl,
        'state': state,
        'username': username
      })
    );
    devolver.codigo = response.statusCode;
    Map<String, dynamic> result = jsonDecode(response.body);
    if(devolver.codigo == 201){
      devolver.mensaje = result['_id'];
      sharedPreferencesProvider.setStringValue('token', result['token']);
    }else{
      switch (devolver.codigo) {
        case 409:
          devolver.mensaje = 'Vaja, el número de teléfon ja existeix';
          break;
        default:
          devolver.mensaje = 'Error inesperat, intenta-ho més tard';
      }
    }
    return devolver;
  }


  Future<Response> loginUser(String phone) async {
    Response devolver = new Response();
    String pushNotificationToken;
    pushNotificationToken = await sharedPreferencesProvider.getStringValue('pushNotificationToken');
     
    http.Response response = await http.post(
      new Uri.http(uri, '/auth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'pushServiceToken': pushNotificationToken,
        'phoneNumber': phone,
      })
    );
    devolver.codigo = response.statusCode;
    Map<String, dynamic> result = jsonDecode(response.body);
    if(devolver.codigo == 200){
      sharedPreferencesProvider.setStringValue('token', result['token']);
    }else{
      switch (devolver.codigo) {
        case 401:
          devolver.mensaje = 'El número de teléfon no està registrat';
          break;
        default:
          devolver.mensaje = 'Error inesperat, intenta-ho més tard';
      }
    }
    return devolver;
  }


  Future<void> verifyPhones(List<Map<String, String>> phones) async {
    Response devolver = new Response();
    String token = await sharedPreferencesProvider.getStringValue('token');

    http.Response response = await http.post(
      new Uri.http(uri, '/user/verify/list'),
      headers: { 
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'numbersList': phones
      })
    );
    devolver.codigo = response.statusCode;
    List result = jsonDecode(response.body);
    if(devolver.codigo == 200){
      await ContactsProvider().crearContactes(result);
    }
  }

  Future<Response> sendUserMessage(String message, String userId) async {
    Response devolver = new Response();
    String token = await sharedPreferencesProvider.getStringValue('token');

    http.Response response = await http.post(
      new Uri.http(uri, '/message/user/' + userId),
      headers: { 
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'message': message
      })
    );
    devolver.codigo = response.statusCode;
    if(devolver.codigo == 200){
      await MessagesProvider().afegirMissatge(message, userId, 1);
    }
    return devolver;
  }

  Future<Map<String, dynamic>> getUserByPhone(String phone) async {
    String token = await sharedPreferencesProvider.getStringValue('token');

    http.Response response = await http.post(
      new Uri.http(uri, '/user/' + phone),
      headers: { 
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      }
    );
    Map<String, dynamic> result = jsonDecode(response.body);
    return result;
  }

  Future<Response> updateUser(String phone, String state, String username, String photoUrl) async {
    Response devolver = new Response();
    String token = await sharedPreferencesProvider.getStringValue('token');
    
    http.Response response = await http.put(
      new Uri.http(uri, '/user/' + phone),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'photo': photoUrl,
        'state': state,
        'username': username
      })
    );
    devolver.codigo = response.statusCode;
    Map<String, dynamic> result = jsonDecode(response.body);
    if(devolver.codigo == 201){
      devolver.mensaje = result['_id'];
    }else{
      switch (devolver.codigo) {
        case 404:
          devolver.mensaje = 'Vaja, no hem trobat l\'usuari';
          break;
        default:
          devolver.mensaje = 'Error inesperat, intenta-ho més tard';
      }
    }
    return devolver;
  }
}
class Response {
  int codigo;
  String mensaje;    
}