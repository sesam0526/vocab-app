import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'friend_vocab_detail.dart';

class FriendVocab extends StatefulWidget {
  String email = '';
   FriendVocab( {super.key, required this.email});

  @override
  _FriendVocab createState() =>  _FriendVocab(email: email);
}

class _FriendVocab extends State<FriendVocab> {
   String email = '';
  _FriendVocab({required this.email});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: const Text('친구의 단어장'),
       // backgroundColor: Colors.purple[300],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getVocabularies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('데이터 로드 중 오류가 발생했습니다.'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('단어장이 없습니다.'));
          }

          var vocabularies = snapshot.data!.docs;
          return ListView.builder(
            itemCount: vocabularies.length,
            itemBuilder: (context, index) {
              var vocabulary = vocabularies[index];
              return ListTile(
                title: Text(vocabulary['name'],style: const TextStyle(fontSize: 25),),
                subtitle: Text(vocabulary['description'] ?? ''),
                onTap: () {
                  
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FriendVocabDetail(
                      vocabularyId: vocabulary.id,
                      vocabularyName: vocabulary['name'],
                      email: email,
                    ),
                  ),
                );
                
              },
               
              );
            },
          );
        },
      ),
     );
  }

    Stream<QuerySnapshot> getVocabularies() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('Vocabularies')
        .snapshots();
  }
}