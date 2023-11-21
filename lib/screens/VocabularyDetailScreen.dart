import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vocabulary_service.dart'; // VocabularyService 클래스를 import합니다.

class VocabularyDetailScreen extends StatefulWidget {
  final String vocabularyId;
  final String vocabularyName;

  const VocabularyDetailScreen({Key? key, required this.vocabularyId, required this.vocabularyName}) : super(key: key);

  @override
  _VocabularyDetailScreenState createState() => _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends State<VocabularyDetailScreen> {
  final VocabularyService _vocabService = VocabularyService();

    Future<void> _showWordOptionsDialog(DocumentSnapshot word) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('단어 설정'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  title: const Text('편집'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addEditWordDialog(wordId: word.id, word: word['word'], meaning: word['meaning']);
                  },
                ),
                ListTile(
                  title: const Text('삭제'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _vocabService.deleteWord(widget.vocabularyId, word.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _addEditWordDialog({String? wordId, String? word, String? meaning}) async {
    final TextEditingController wordController = TextEditingController(text: word);
    final TextEditingController meaningController = TextEditingController(text: meaning);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(wordId == null ? '새 단어 추가' : '단어 수정'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: wordController,
                  decoration: const InputDecoration(hintText: "단어"),
                  autofocus: true,
                ),
                TextField(
                  controller: meaningController,
                  decoration: const InputDecoration(hintText: "의미"),
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
      child: const Text('저장'),
      onPressed: () async {
        if (wordController.text.isNotEmpty && meaningController.text.isNotEmpty) {
          if (wordId == null) {
            // 새 단어 추가 로직
            await _vocabService.addWord(widget.vocabularyId, wordController.text, meaningController.text);
          } else {
            // 단어 수정 로직
            await _vocabService.updateWord(widget.vocabularyId, wordId, wordController.text, meaningController.text);
          }
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
        title: Text(widget.vocabularyName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore에서 해당 단어장의 단어 목록을 가져오는 스트림
        stream: _vocabService.getWords(widget.vocabularyId),
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
                onTap: () {
                  // 단어 수정 대화상자 표시
                  _addEditWordDialog(wordId: word.id, word: word['word'], meaning: word['meaning']);
                },
                onLongPress: () {
                  _showWordOptionsDialog(word);                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새 단어 추가 대화상자 표시
          _addEditWordDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}