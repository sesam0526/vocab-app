import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WrongWordsScreen extends StatefulWidget {
  const WrongWordsScreen({Key? key}) : super(key: key);

  @override
  _WrongWordsScreenState createState() => _WrongWordsScreenState();
}

class _WrongWordsScreenState extends State<WrongWordsScreen> {
  List<Map<String, dynamic>> vocabularyList = [];

  @override
  void initState() {
    super.initState();
    fetchVocabularies();
  }

  Future<void> fetchVocabularies() async {
    String uid = 'abc'; // 사용자의 UID 또는 이메일로 변경
    FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser != null) {
      uid = auth.currentUser!.email.toString();
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("Vocabularies")
        .get();

    setState(() {
      vocabularyList = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'].toString(),
                'description': doc['description'].toString(),
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오답 노트'),
        backgroundColor: Colors.purple[400],
      ),
      body: ListView.builder(
        itemCount: vocabularyList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(vocabularyList[index]['name']),
            subtitle: Text(vocabularyList[index]['description']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VocabularyWrongWordsScreen(
                    vocabularyId: vocabularyList[index]['id'],
                    vocabularyName: vocabularyList[index]['name'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class VocabularyWrongWordsScreen extends StatefulWidget {
  final String vocabularyId;
  final String vocabularyName;

  const VocabularyWrongWordsScreen({
    Key? key,
    required this.vocabularyId,
    required this.vocabularyName,
  }) : super(key: key);

  @override
  _VocabularyWrongWordsScreenState createState() =>
      _VocabularyWrongWordsScreenState();
}

class _VocabularyWrongWordsScreenState
    extends State<VocabularyWrongWordsScreen> {
  List<Map<String, dynamic>> wrongWordsList = [];

  @override
  void initState() {
    super.initState();
    fetchWrongWords();
  }

  Future<void> fetchWrongWords() async {
    String uid = 'abc'; // 사용자의 UID 또는 이메일로 변경
    FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser != null) {
      uid = auth.currentUser!.email.toString();
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("Vocabularies")
        .doc(widget.vocabularyId)
        .collection("WrongWords")
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
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              '틀린 단어 목록',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            if (wrongWordsList.isEmpty)
              const Text('틀린 단어가 없습니다.')
            else
              Column(
                children: wrongWordsList.map((wrongWord) {
                  return ListTile(
                    title: Text(wrongWord['word']),
                    subtitle: Text(
                        '뜻: ${wrongWord['meaning']}, 틀린 횟수: ${wrongWord['incorrectCount']}'),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
