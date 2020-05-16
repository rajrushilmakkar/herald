import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:herald/widgets/contactTab.dart';
import 'package:herald/widgets/homescreen.dart';
import 'package:permission_handler/permission_handler.dart';

class chat_screen extends StatefulWidget {
  final number;
  chat_screen(this.number);
  @override
  _chat_screenState createState() => _chat_screenState();
}

class _chat_screenState extends State<chat_screen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    _tabController = new TabController(length: 1, vsync: this);

    // TODO: implement initState
    super.initState();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () async {
            await _auth.signOut();
            print('Signed Out');
            Navigator.of(context)
                .pushReplacement(new MaterialPageRoute(builder: (context) {
              return Home();
            }));
          },
        ),
        title: Text('Herald-A Chatting App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              text: 'Contacts',
              icon: Icon(Icons.contact_phone),
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          ContactTab(widget.number),
          //ContactTab(widget.number),
        ],
      ),
    );
  }
}
