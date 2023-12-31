import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/screens/VocabularyDetailScreen.dart';
import 'vocabulary_service.dart'; // VocabularyService 클래스를 import합니다.

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  _VocabularyScreenState createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final VocabularyService _vocabService = VocabularyService();
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 안내 메시지 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('단어장를 길게 눌러 편집 또는 삭제할 수 있습니다.'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

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

  Future<void> _showEditDeleteDialog(DocumentSnapshot vocabulary) async {
    final TextEditingController nameController = TextEditingController(text: vocabulary['name']);
    final TextEditingController descriptionController = TextEditingController(text: vocabulary['description']);

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('단어장 수정 / 삭제'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "단어장 이름"),
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
              child: const Text('삭제'),
              onPressed: () async {
                await _vocabService.deleteVocabulary(vocabulary.id);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('수정'),
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await _vocabService.updateVocabulary(vocabulary.id, nameController.text, descriptionController.text);
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
        backgroundColor: Colors.purple[400],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _vocabService.getVocabularies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('데이터 로드 중 오류가 발생했습니다.'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('단어장이 없습니다. 새로운 단어장을 추가해보세요!'));
          }

          var vocabularies = snapshot.data!.docs;
          return ListView.builder(
            itemCount: vocabularies.length,
            itemBuilder: (context, index) {
              var vocabulary = vocabularies[index];
              return ListTile(
                title: Text(vocabulary['name']),
                subtitle: Text(vocabulary['description'] ?? ''),
                onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VocabularyDetailScreen(
                      vocabularyId: vocabulary.id,
                      vocabularyName: vocabulary['name'],
                    ),
                  ),
                );
              },
                onLongPress: () => _showEditDeleteDialog(vocabulary),
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
