import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class ContactTab extends StatefulWidget {
  final number;
  ContactTab(this.number);
  @override
  _ContactTabState createState() => _ContactTabState();
}

//List<Contact> contacts;
List<Contact> _contacts = []; //phone contacts
Firestore _firestore = Firestore.instance;
List contacts; //firebase conatacts list of list tiles
List fire_contacts = []; //firebase numbers list
var uid;

class _ContactTabState extends State<ContactTab> {
  void loadContacts() async {
    _contacts =
        (await (ContactsService.getContacts(withThumbnails: false))).toList();

    //_contacts = val.toList();

    setState(() {
      _contacts = _contacts;
      //for(contact in _contacts)
    });
    // print(numbers.elementAt(0));
  }

  @override
  void initState() {
    // TODO: implement initState
    FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        uid = val.uid;
      });
    }).catchError((e) {
      print(e);
    });
    super.initState();
    loadContacts();
  }

  List<DocumentSnapshot> docs;
  List<Map> matching_contacts = [];
  @override
  Widget build(BuildContext context) {
    return _contacts == null
        ? Text('No Contacts')
        : StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator()),
                );
              } else {
                docs = snapshot.data.documents;
                //docs_data = snapshot.data[];

                /*List<Widget> requests = docs.map((doc) {
      Requests(doc.data['latitude'], doc.data['longitude'], doc.data['img'],
      doc.data['date']);
    }).toList();*/
                /* return ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, ind) {
                    Contact contact = _contacts.elementAt(ind);
                    return (contact.displayName != null &&
                            contact.phones.isNotEmpty &&
                            contact.initials().isNotEmpty)
                        ? Container(
                            decoration:
                                BoxDecoration(border: Border.all(width: 0.5)),
                            child: ListTile(
                              title: Text(
                                contact.displayName,
                              ),
                              subtitle: Text(contact.phones.elementAt(0).value),
                              leading: CircleAvatar(
                                child: Text(contact.initials()),
                              ),
                            ),
                          )
                        : Container();
                  },
                  itemCount: _contacts.length,
                );*/
                contacts = getContacts(context, docs);
                getContacts1(context, docs); //list of listiles

                matchingContacts();
                //print(matching_contacts);
                return ListView.builder(
                    itemCount: matching_contacts.length,
                    itemBuilder: (context, ind) {
                      return Container(
                        decoration:
                            BoxDecoration(border: Border.all(width: 0.5)),
                        child: ListTile(
                          title: Text(matching_contacts[ind]['name']),
                          subtitle: Text(matching_contacts[ind]['number']),
                          leading: CircleAvatar(
                            child: Text(matching_contacts[ind]['name'][0]),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => Chat(
                                        toNumber: matching_contacts[ind]
                                            ['number'],
                                        toName: matching_contacts[ind]['name'],
                                        myNum: widget.number)));
                          },
                        ),
                      );
                    });
              }
            },
          );
  }

  void matchingContacts() {
    Contact contact; //to store phone contact one by one
    var i, j;
    bool check;
    for (contact in _contacts) {
      //print('phony' + contact.phones.elementAt(0).value);
      //print(contact.phones.elementAt(0).value.trim());

      //
      //contact.phones.elementAt(0).value.replaceAll('     ', '');
      // contact.phones.elementAt(0).value.replaceAll('    ', '');

      //contact.phones.elementAt(0).value.replaceAll('   ', '');
      //
      if (contact.displayName != null && contact.phones.isNotEmpty) {
        // contact.phones.elementAt(0).value =
        //contact.phones.elementAt(0).value.toString();
        /*  contact.phones.elementAt(0).value = contact.phones
            .elementAt(0)
            .value
            .replaceAll(new RegExp(r"\s+\b|\b\s"), '');
        contact.phones.elementAt(0).value =
            contact.phones.elementAt(0).value.replaceAll(' ', '');*/

        //print('Reading ' + contact.phones.elementAt(0).value);
        //contact.phones.elementAt(0).value.replaceAll('  ', '');
        //contact.phones.elementAt(0).value.replaceAll(' ', '');
        //contact.phones.elementAt(0).value.trim();
        for (i
            in fire_contacts) // i is  contact one by one from firebase,contacts are firebase contacts
        {
          //print(i.toString().replaceAll(' ', ''));
          if (i == widget.number) continue;
          //print(i + ' from fire base');
          int m;
          for (m = 0; m < contact.phones.length; m++) {
            if (contact.phones.elementAt(m).value.replaceAll(' ', '') ==
                i.toString().replaceAll(' ', '')) {
              check = false;
              for (j in matching_contacts) {
                if (i == j['number']) {
                  check = true;
                  break;
                }
              }
              if (check == false) {
                matching_contacts
                    .add({'name': contact.displayName, 'number': i});
                // print('adding_entries' + widget.number);
              }
            }
          }
        }
      }
    }
  }
}

List getContacts(BuildContext context, List<DocumentSnapshot> docs) {
  return docs.map((doc) {
    var number = doc.data['number'];
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 0.5)),
      child: ListTile(
        title: Text(number),
      ),
    );
  }).toList();
}

List getContacts1(BuildContext context, List<DocumentSnapshot> docs) {
  return docs.map((doc) {
    var number = doc.data['number'];
    //print('adding fire' + number);
    fire_contacts.add(number);
  }).toList();
}
