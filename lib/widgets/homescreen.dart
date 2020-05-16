//import 'dart:js_util';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:herald/widgets/RoundButton.dart';
import 'package:herald/widgets/chat_screen.dart';

import 'db_helper.dart';

class Home extends StatefulWidget {
  // final myNum;
  //Home(this.myNum);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //String verId;

  var number;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  String otp, verificationId;

  Future<void> sendOTP() async {
    //print('ha');

    final PhoneCodeAutoRetrievalTimeout autoRetrieval = (String verId) {
      this.verificationId = verId;
    };
    final PhoneCodeSent smsCodesent =
        (String verId, [int forceCodeResendToken]) {
      this.verificationId = verId;
      Fluttertoast.showToast(
          msg: 'Code sent',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          fontSize: 20);
    };
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential credential) {
      number = number.toString();
      number = '+91 ' + number.substring(0, 5) + ' ' + number.substring(5, 10);
      updateC(number);
      _auth.signInWithCredential(credential).then((user) {
        bool newUser = user.additionalUserInfo.isNewUser;
        if (newUser == true) {
          addUser();
        }

        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (BuildContext context) => chat_screen(number)));
        Fluttertoast.showToast(
            msg: 'Log in successful',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            fontSize: 20);
      }).catchError((e) {
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            fontSize: 20);
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (AuthException exception) {
      print('${exception.message}');
      Fluttertoast.showToast(
          msg: exception.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          fontSize: 20);
    };
    var number1 = '+91' + number;
   // print(number);
    await _auth.verifyPhoneNumber(
        phoneNumber: number1,
        timeout: Duration(seconds: 120),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsCodesent,
        codeAutoRetrievalTimeout: autoRetrieval);
  }

  var uid;
  void addUser() async {
    FirebaseAuth.instance.currentUser().then((val) {
      uid = val.uid;
      _firestore.collection(uid).add({
        //'uid': uid,
        'number': number,
      });
      _firestore.collection('users').add({
        'number': number,
        'uid': uid,
      });
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> updateC(String number) async {
    await DBHelper.insert('status', {'id': 'c', 'value': number});
  }

  Firestore _firestore = Firestore.instance;
  void login() async {
    number = number.toString();
    number = '+91 ' + number.substring(0, 5) + ' ' + number.substring(5, 10);
    updateC(number);
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: otp,
    );

    _auth.signInWithCredential(credential).then((user) {
      bool newUser = user.additionalUserInfo.isNewUser;
      if (newUser == true) {
        addUser();
      }

      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => chat_screen(number)));
      Fluttertoast.showToast(
          msg: 'Log in successful',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          fontSize: 20);
    }).catchError((e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          fontSize: 20);
    });
  }

  TextEditingController phone;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Herald'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: phone,
              decoration: InputDecoration(
                  hintText: 'Enter your mobile number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                number = val;
              },
            ),
          ),
          RoundButton(sendOTP, 'Send OTP'),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              //controller: OTP,

              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30))),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                otp = val;
              },
            ),
          ),
          RoundButton(login, 'Log In'),
        ],
      ),
    );
  }
}
