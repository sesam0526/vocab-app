import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'wrongVocabulary_detail.dart';

class WrongVocabularyScreen extends StatefulWidget {
  const WrongVocabularyScreen({Key? key}) : super(key: key);

  @override
  _WrongVocabularyScreenState createState() => _WrongVocabularyScreenState();
}

class _WrongVocabularyScreenState extends State<WrongVocabularyScreen> {
  List<Map<String, dynamic>> vocabularyList = [];

  @override
  void initState() {
    super.initState();
    fetchVocabularies();
  }

  Future<void> fetchVocabularies() async {
    String uid = 'abc'; // 사용자의 uid
    FirebaseAuth auth = FirebaseAuth.instance; // 사용자 인증관련 작업 수행

    if (auth.currentUser != null) {
      // 현재 사용자가 인증되어 있으면
      uid = auth.currentUser!.email.toString(); // 사용자의 이메일을 UID로 사용
    }

    try {
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
    } catch (error) {
      print('Error fetching vocabulary data: $error');
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('오류'),
          content: const Text('데이터 로드 중 오류가 발생했습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('닫기'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오답 노트'),
        backgroundColor: Colors.purple[400],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (vocabularyList.isEmpty)
            const Center(
              child: Text('단어장이 없습니다. 단어장을 먼저 추가해주세요!'),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: vocabularyList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(vocabularyList[index]['name']),
                    subtitle: Text(vocabularyList[index]['description']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WrongVocabularyDetail(
                            vocabularyId: vocabularyList[index]['id'],
                            vocabularyName: vocabularyList[index]['name'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
