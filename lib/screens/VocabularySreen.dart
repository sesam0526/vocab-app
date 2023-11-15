import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/vocabulary_service.dart';
//import 'vocabulary_service.dart'; // VocabularyService 클래스를 import합니다.

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  _VocabularyScreenState createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final VocabularyService _vocabService = VocabularyService();

  Future<void> _addVocabularyDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('새 단어장 추가'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "단어장 이름"),
                  autofocus: true,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(hintText: "설명 (선택사항)"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('추가'),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await _vocabService.addVocabulary(nameController.text, descriptionController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('단어장'),
      ),
      body: StreamBuilder<QuerySnapshot>(
      stream: _vocabService.getVocabularies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('데이터 로드 중 오류가 발생했습니다.'));
        }

        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Center(child: Text('단어장이 없습니다. 새로운 단어장을 추가해보세요!'));
        }

        var vocabularies = snapshot.data!.docs;
        return ListView.builder(
          itemCount: vocabularies.length,
          itemBuilder: (context, index) {
            var vocabulary = vocabularies[index];
            return ListTile(
              title: Text(vocabulary['name']),
              subtitle: Text(vocabulary['description'] ?? ''),
            );
          },
        );
      },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVocabularyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
