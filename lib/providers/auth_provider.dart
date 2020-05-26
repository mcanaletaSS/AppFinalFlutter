import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:saleschat/providers/contacts_provider.dart';
import 'package:saleschat/providers/http_provider.dart';
import 'package:saleschat/providers/preferences_provider.dart';

class AuthProvider {
  Future<void> signIn(BuildContext context, AuthCredential authCreds, bool isLogin, String phone) async {
    String route;
    isLogin ? route = 'login' : route = 'verifyPhone';
    try{
      await FirebaseAuth.instance.signInWithCredential(authCreds);
      await sharedPreferencesProvider.setStringValue('phone', phone);
      if(!isLogin) {
        Navigator.pushNamed(context, 'signin');
      }else{
        Response response = await HttpProvider().loginUser(phone);
        if(response.codigo == 200){
          List<Map<String, String>> phones = await ContactsProvider().getContactsPhones();
          await HttpProvider().verifyPhones(phones);
          Navigator.pushNamed(context, 'chats');
        }else{
          mostrarAlert(context, route);
        }
      }
    }catch(err){
      mostrarAlert(context, route);
    }
  }
  Future<void> signInWithOTP(BuildContext context, String smsCode, String verId, bool isLogin, String phone) async {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
      verificationId: verId,
      smsCode: smsCode
    );
    await signIn(context, authCreds, isLogin, phone);
  }
  
  void mostrarAlert(BuildContext context, String route) {
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
              'Sembla que hi ha hagut algun error a l\'hora de verificar el número! Sisuplau, torna a intentar-ho en uns minuts',
              textAlign: TextAlign.center,
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).popUntil(ModalRoute.withName(route)),
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