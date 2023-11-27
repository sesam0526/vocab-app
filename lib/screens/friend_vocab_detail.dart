
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendVocabDetail extends StatefulWidget {
  //이 창은 단어장 아이디, 이름,유저 이메일을 받아서 구성
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
        backgroundColor: Colors.purple[400],
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
                //단어와 그 뜻으로 구성
                title: Text(word['word']),
                subtitle: Text(word['meaning']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 내 단어장으로 받아오는 버튼
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

  //해당 단어장의 단어들을 받기 위한 함수
  Query<Map<String, dynamic>> getWords(String vocabularyId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.email)
        .collection('Vocabularies')
        .doc(vocabularyId)
        .collection('Words')
        .orderBy('timestamp', descending: false);
  }
 
 //나의 단어장에 친구의 단어장을 추가하는 함수
  Future<void> addVocabulary(
      String vocalId, String name, String description) async {
    //받아올 단어장은 DB에 '단어장이름'+'친구단어장 아이디'의 형식으로 저장 
    String docName = name + vocalId;
    User? user = auth.currentUser;
    if (user != null) {
      //i는 단어장을 다운했는지 확인을 위한 변수
      int i;
      //받아오려는 단어장의 docname으로 DB에 데이터가 있는지 확인을 위해 받아옴
      DocumentSnapshot snapshot=await FirebaseFirestore.instance
              .collection('users')
              .doc(user.email.toString())
              .collection('Vocabularies')
              .doc(docName).get();
      if (snapshot.data()==null) {
          //만약 데이터가 없다면 받아온 적 없는 단어장임
        //내 단어장에 단어장 만들기
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
        //친구 단어장을 돌면서 값을 새로 만든 내 단어장에 저장하기
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
        //다운을 했으면 i는 0
        i=0;
      } else {
        //다운을 못했으면 i는 1
        i=1;
      }
      //i의 값에 따라 사용자에게 출력할 메시지가 달라짐
      downloadCheck(i);
    }
  }

  Future<void> downloadCheck(int i) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          if(i==0){
            //i가 0인 경우는 다운을 했을 때
            return const AlertDialog(
            title: Text(
              '다운 성공',
              style: TextStyle(fontSize: 20),
            ),
          );
          }else{
            //0이 아닌 경우는 다운을 하지 못한, 즉 이미 다운받은 적 있는 단어장이기에 실패한 경우
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
