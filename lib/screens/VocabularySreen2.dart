// User? currentUser = _auth.currentUser;
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({Key? key}) : super (key: key);

  @override
  _VocabularyScreenState createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    final String currentUserId = _auth.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('단어장'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('Users').doc(currentUserId).collection('Vocabularies').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var vocabularies = snapshot.data!.docs;
          return ListView.builder(
            itemCount: vocabularies.length,
            itemBuilder: (context, index) {
              var vocabulary = vocabularies[index];
              return ListTile(
                title: Text(vocabulary['name']),
                // 여기에 추가적인 기능을 구현할 수 있습니다.
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 여기에 단어장 추가 기능을 구현할 수 있습니다.
        },
        child: Icon(Icons.add),
      ),
    );
  }
}*/