import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'friend_vocab_detail.dart';

class FriendVocab extends StatefulWidget {
  //친구 단어장을 불러올때 친구 이메일 값을 받아서 구성
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
          //연결중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          //오류가 발생했을 때
          if (snapshot.hasError) {
            return const Center(child: Text('데이터 로드 중 오류가 발생했습니다.'));
          }
          //단어장이 존재하지 않을 때
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('단어장이 없습니다.'));
          }

          var vocabularies = snapshot.data!.docs;
          //친구의 단어장 리스트 만들기
          return ListView.builder(
            itemCount: vocabularies.length,
            itemBuilder: (context, index) {
              var vocabulary = vocabularies[index];
              return ListTile(
                //단어장 이름, 세부설명(존재하지 않을 수 있음)
                title: Text(vocabulary['name'],style: const TextStyle(fontSize: 25),),
                subtitle: Text(vocabulary['description'] ?? ''),
                onTap: () {
                //단어장을 누르면 그 단어장 안의 단어를 볼 수 있는 창으로 이동, 이 때 단어장의 id를 가지고 창 구성
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
//해당 이메일의 단어장을 불러올 함수
    Stream<QuerySnapshot> getVocabularies() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('Vocabularies')
        .snapshots();
  }
}