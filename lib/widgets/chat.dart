//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:herald/main.dart';
//import 'package:herald/main.dart';

class Chat extends StatefulWidget {
  final toName, toNumber, myNum;
  Chat({this.toName, this.toNumber, this.myNum});
  //final myName, myNumber;
  @override
  _ChatState createState() => _ChatState();
}

String toName1;
String myNumber;
String message;
Firestore _firestore = Firestore.instance;
List<DocumentSnapshot> docs;

class _ChatState extends State<Chat> {
  ScrollController _controller = new ScrollController();

  TextEditingController msg = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    // _controller.animateTo(_controller.position.maxScrollExtent,
    //  duration: Duration(milliseconds: 100), curve: Curves.easeOut);

    myNumber = widget.myNum;
    toName1 = widget.toName;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    msg.dispose();
    super.dispose();
  }

  void sendMsg() async {
    if (message.length > 0) {
      await _firestore.collection('messages').add({
        'date': DateTime.now(),
        'from': widget.myNum,
        'to': widget.toNumber.toString(),
        'message': message,
      }).whenComplete(() {
        setState(() {
          msg.text = '';
          message = '';
          _controller.animateTo(_controller.position.maxScrollExtent,
              duration: Duration(milliseconds: 100), curve: Curves.easeOut);
          // _controller.jumpTo(_controller.position.maxScrollExtent);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /*SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_controller.positions.length > 0 &&
          _controller.position.extentAfter == 0.0) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
      //_controller.jumpTo(_controller.position.maxScrollExtent);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_controller.positions.length > 0 &&
          _controller.position.extentAfter == 0.0) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });*/
    //_controller.initialScrollOffset = _controller.position.maxScrollExtent;
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
              child: Text(toName1[0]),
            ),
            Text('  ' + widget.toName)
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          StreamBuilder(
            stream:
                _firestore.collection('messages').orderBy('date').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data == null) {
                return SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                );
              } else {
                docs = snapshot.data.documents;
                List<Widget> messages = docs.map((doc) {
                  if ((doc.data['to'] == widget.toNumber &&
                          doc.data['from'] == widget.myNum) ||
                      (doc.data['from'] == widget.toNumber &&
                          doc.data['to'] == widget.myNum)) {
                    return Messages(
                      from: doc.data['from'],
                      to: doc.data['to'],
                      message: doc.data['message'],
                    );
                  } else {
                    return Container();
                  }
                }).toList();
                return Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    controller: _controller,
                    children: <Widget>[
                      ...messages,
                    ],
                  ),
                );
              }
            },
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Type your Message',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30))),
                    controller: msg,
                    onSubmitted: (val) {
                      sendMsg();
                    },
                    onChanged: (val) {
                      message = val;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMsg,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Messages extends StatelessWidget {
  final String from;
  final String message;
  final String to;

  const Messages({Key key, this.from, this.message, this.to}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var name;
    bool me = false;
    if (from == myNumber) {
      // Fluttertoast.showToast(msg: my)
      me = true;
      name = 'My Number';
    } else {
      name = toName1;
    }
    // bool me;
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(name),
          ),
          Material(
            color: me ? Colors.blue : Colors.orange,
            borderRadius: BorderRadius.circular(20.0),
            elevation: 6.0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Text(message)),
            ),
          ),
        ],
      ),
    );
  }
}
