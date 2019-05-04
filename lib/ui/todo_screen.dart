import 'package:flutter/material.dart';
import './add_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_assignment_03/model/firestore_model.dart';

class TodoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodoScreenState();
  }
}

class TodoScreenState extends State {
  int _current_state = 0;
  
  Widget build(BuildContext context) {
    List current_tab = <Widget>[
      IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TodoAdd()));
        },
      ),
      IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          FirestoreUtils.deleteAllDone();
        },
      )
    ];

    List current_screen = [
      StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
          .collection('todo')
          .where('done', isEqualTo: false)
          .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: Text('LOADDATA'),
            );
          default:
            return snapshot.data.documents.length == 0 ? Center(child: Text('No data found...')):
                  ListView(
                    children: snapshot.data.documents.map((DocumentSnapshot document) {
                      return Column(
                        children: <Widget>[
                          Divider(
                            height: 5.0,
                          ),
                          CheckboxListTile(
                            title: Text(document['title']),
                            value: document['done'],
                            onChanged: (bool value) {
                              FirestoreUtils.update(document.documentID, value);
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  );
          }
        },
      ),
      StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
          .collection('todo')
          .where('done', isEqualTo: true)
          .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: Text('LOADDATA'),
            );
          default:
            return snapshot.data.documents.length == 0 ? Center(child: Text('No data found...')):
                ListView(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) {
                      return Column(
                        children: <Widget>[
                          Divider(
                            height: 5.0,
                          ),
                          CheckboxListTile(
                            title: Text(document['title']),
                            value: document['done'],
                            onChanged: (bool value) {
                              FirestoreUtils.update(document.documentID, value);
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  );
          }
        },
      ),
    ];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Todo"),
          actions: <Widget>[
            _current_state == 0 ? current_tab[0] : current_tab[1]
          ],
          backgroundColor: Colors.blue,
        ),
        body: Center(child: _current_state == 0 ? current_screen[0] : current_screen[1]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _current_state,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.list), title: Text('Task')),
            BottomNavigationBarItem(
                icon: Icon(Icons.done_all), title: Text('Completed'))
          ],
          onTap: (int index) {
            setState(() {
              _current_state = index;
            });
          },
        ),
      ),
    );
  }
}
