import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WrongVocabularyDetail extends StatefulWidget {
  final String vocabularyId;
  final String vocabularyName;

  const WrongVocabularyDetail({
    Key? key,
    required this.vocabularyId,
    required this.vocabularyName,
  }) : super(key: key);

  @override
  _WrongVocabularyDetailState createState() => _WrongVocabularyDetailState();
}

class _WrongVocabularyDetailState extends State<WrongVocabularyDetail> {
  List<Map<String, dynamic>> wrongWordsList = [];

  @override
  void initState() {
    super.initState();
    fetchWrongWords();
  }

  Future<void> fetchWrongWords() async {
    String uid = 'abc'; // 사용자 uid
    FirebaseAuth auth = FirebaseAuth.instance; // 사용자 인증관련 작업 수행

    if (auth.currentUser != null) {
      // 현재 사용자가 인증되어 있으면
      uid = auth.currentUser!.email.toString(); // 사용자의 이메일을 UID로 사용
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("Vocabularies")
        .doc(widget.vocabularyId)
        .collection("WrongWords")
        .orderBy('incorrectCount', descending: true) // 틀린 횟수 많은 순서대로 정렬
        .get();

    setState(() {
      wrongWordsList = snapshot.docs
          .map((doc) => {
                'word': doc['word'].toString(),
                'meaning': doc['meaning'].toString(),
                'incorrectCount': doc['incorrectCount'],
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vocabularyName} - 오답 노트'),
        backgroundColor: Colors.purple[400],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text(
              '틀린 단어 목록',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: Column(
                children: wrongWordsList.isEmpty
                    ? [
                        const Text('틀린 단어가 없습니다.'),
                      ]
                    : wrongWordsList.map((wrongWord) {
                        return ListTile(
                          title: Text(wrongWord['word']),
                          subtitle: Text(
                              '뜻: ${wrongWord['meaning']}, 틀린 횟수: ${wrongWord['incorrectCount']}'),
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
