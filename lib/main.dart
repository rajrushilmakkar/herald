import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:herald/widgets/chat_screen.dart';
import 'package:herald/widgets/db_helper.dart';
import 'package:herald/widgets/homescreen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

var uid;
Firestore _firestore = Firestore.instance;
String myNum;

class _MyAppState extends State<MyApp> {
  /* getData()  {
    return StreamBuilder(
      stream: _firestore.collection(uid).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data != null) {
          List<DocumentSnapshot> docs = snapshot.data.documents;
          docs.map((doc) {
            myNum = doc.data['number'];
          });
          print('chika');
          print('chika chika' + myNum);
        }
        return null;
      },
    );
  }
*/
  // List<Map<String, Object>> status;
  //DBHelper.insert('status',{'id':'c','value':1});
  getData() async {
    DBHelper.getData('status').then((status) {
      //print(status.first['value']);
      myNum = status.first['value'];
      //return status.first['value'];
    });
  }

  @override
  void initState() {
    getPermission();

    getData();
    //print(myNum);
    FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        uid = val.uid;
        //print(uid);
        //var x=getData();
      });
    }).catchError((e) {
      print(e);
    });
    //myNum = '+91 99109 07009';

    // TODO: implement initState
    super.initState();
  }

  getPermission() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.contacts].request();
    print(statuses[Permission.location]);
  }

  void load(BuildContext context) async {
    Future.delayed(Duration(seconds: 4), () {
      if (uid == null) {
        Navigator.of(context)
            .pushReplacement(new MaterialPageRoute(builder: (context) {
          return Home();
        }));
      } else {
        Navigator.of(context)
            .pushReplacement(new MaterialPageRoute(builder: (context) {
          return chat_screen(myNum);
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //myNum = getData().toString();
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            load(context);
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                height: 40,
                width: 40,
              ),
            );
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
