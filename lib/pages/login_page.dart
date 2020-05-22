import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saleschat/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final formKey = new GlobalKey<FormState>();
  String phoneNo, verificationId, smsCode;
  
  bool codeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text('Iniciar Sessió'),
         leading: Icon(Icons.person)
       ),
       body: _loginForm()
    );
  }
  
  Widget _loginForm(){
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          !codeSent ? _phoneTextField() : SizedBox(),
          codeSent ? _smsCodeTextField() : SizedBox(),
          _verifyButton()
        ],
      ),
    );
  }

  Widget _phoneTextField() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Número de Telèfon',
          labelStyle: TextStyle(
            fontSize: 20
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Icon(
              Icons.phone,
              size: 30,
            ),
          ),
          prefixText: '+34 '
        ),
        style: TextStyle(
          fontSize: 30,
        ),
        maxLength: 9,
        onChanged: (val) {
          setState(() {
            this.phoneNo = '+34' + val;
          });
        },
      ),
    );
  }

  Widget _smsCodeTextField() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Codi de verificació',
          labelStyle: TextStyle(
            fontSize: 20,
            letterSpacing: 0
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 15.0, right: 10.0),
            child: Icon(
              Icons.message,
              size: 30,
            ),
          ),
        ),
        style: TextStyle(
          fontSize: 35,
          letterSpacing: 20
        ),
        maxLength: 6,
        textAlign: TextAlign.center,
        onChanged: (val) {
          setState(() {
            this.smsCode = val;
          });
        },
      ),
    );
  }

  Widget _verifyButton() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 100.0),
        child: OutlineButton(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2
          ),
          child: Center(
            child: codeSent ? 
              Text('Comprova', style: TextStyle(color: Colors.red)) 
              :
              Text('Verifica', style: TextStyle(color: Colors.red)),
          ),
          onPressed: () {
            codeSent ? AuthProvider().signInWithOTP(context, smsCode, verificationId, true, phoneNo) : verifyPhone(context, phoneNo);
          }
        ),
      ),
    );
  }

  Future<void> verifyPhone(BuildContext context, String phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthProvider().signIn(context, authResult, true, phoneNo);
    };

    final PhoneVerificationFailed verificationfailed = (AuthException authException) {
      AuthProvider().mostrarAlert(context, 'login');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };
    
    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNo,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verified,
      verificationFailed: verificationfailed,
      codeSent: smsSent,
      codeAutoRetrievalTimeout: autoTimeout
    );
  }
}