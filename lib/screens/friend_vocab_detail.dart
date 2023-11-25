
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendVocabDetail extends StatefulWidget {
  final String vocabularyId;
  final String vocabularyName;
  final String email;

  const FriendVocabDetail(
      {Key? key,
      required this.vocabularyId,
      required this.vocabularyName,
      required this.email})
      : super(key: key);

  @override
  _FriendVocabDetail createState() => _FriendVocabDetail();
}

class _FriendVocabDetail extends State<FriendVocabDetail> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vocabularyName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore에서 해당 단어장의 단어 목록을 가져오는 스트림
        stream: getWords(widget.vocabularyId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var words = snapshot.data!.docs;

          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              var word = words[index];
              return ListTile(
                title: Text(word['word']),
                subtitle: Text(word['meaning']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 내 단어장으로 받아오기
          await addVocabulary(widget.vocabularyId, widget.vocabularyName,
              '${widget.email}의 단어장');
        },
        label: const Text(
          '단어장 다운',
          style: TextStyle(fontSize: 20),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Query<Map<String, dynamic>> getWords(String vocabularyId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.email)
        .collection('Vocabularies')
        .doc(vocabularyId)
        .collection('Words')
        .orderBy('timestamp', descending: false);
  }

  Future<void> addVocabulary(
      String vocalId, String name, String description) async {
    String docName = name + description;
    //나의 단어장에 단어장 추가
    User? user = auth.currentUser;
    if (user != null) {
      int i;
      DocumentSnapshot snapshot=await FirebaseFirestore.instance
              .collection('users')
              .doc(user.email.toString())
              .collection('Vocabularies')
              .doc(docName).get();
      if (snapshot.data()==null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email.toString())
            .collection('Vocabularies')
            .doc(docName)
            .set({'name': name, 'description': description});
        //친구 단어장 가져오기
        CollectionReference<Map<String, dynamic>> collectionReference =
            FirebaseFirestore.instance
                .collection('users')
                .doc(widget.email)
                .collection('Vocabularies')
                .doc(vocalId)
                .collection('Words');
        QuerySnapshot<Map<String, dynamic>> query =
            await collectionReference.get();
        print(query.docs.length);
        for (var doc in query.docs) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.email.toString())
              .collection('Vocabularies')
              .doc(docName)
              .collection('Words')
              .add({
            'word': doc['word'],
            'meaning': doc['meaning'],
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
        i=0;
      } else {
        i=1;
      }
      downloadCheck(i);
    }
  }

  Future<void> downloadCheck(int i) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          if(i==0){
            return const AlertDialog(
            title: Text(
              '다운 성공',
              style: TextStyle(fontSize: 20),
            ),
          );
          }else{
             return const AlertDialog(
            title: Text(
              '이미 다운받은 단어장입니다.',
              style: TextStyle(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('재다운하고 싶다면 단어장에서 삭제 후 시도하세요.'),
                ],
              ),
            ),
          );
          
          }
          
        });
  }
}
