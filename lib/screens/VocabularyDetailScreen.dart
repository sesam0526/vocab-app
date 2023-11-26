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

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    // 화면 로드 시 안내 메시지 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('단어를 길게 눌러 편집 또는 삭제할 수 있습니다.'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

    Future<void> _showWordOptionsDialog(DocumentSnapshot word) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('단어 설정'),
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
                String inputWord = wordController.text.trim();
                String inputMeaning = meaningController.text.trim();

                if (inputWord.isNotEmpty && inputMeaning.isNotEmpty) {
          // 중복 체크
          bool isDuplicate = await _vocabService.checkWordExistence(widget.vocabularyId, inputWord, wordId);
          if (isDuplicate) {
            // 중복되는 단어가 존재한다는 메시지를 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미 존재하는 단어입니다. 다른 단어를 입력해주세요.'))
            );
            return;
          }

          // 단어 저장 로직
          if (wordId == null) {
            await _vocabService.addWord(widget.vocabularyId, inputWord, inputMeaning);
          } else {
            await _vocabService.updateWord(widget.vocabularyId, wordId, inputWord, inputMeaning);
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
        /*actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 버튼을 눌렀을 때 동작
              setState(() {
                _searchTerm = _searchController.text;
              });
            },
          ),
        ],*/
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: '단어 검색',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
          ),
        ),
      ),
      


      body: StreamBuilder<QuerySnapshot>(
        // Firestore에서 해당 단어장의 단어 목록을 가져오는 스트림
        stream: _vocabService.getWords(widget.vocabularyId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var words = snapshot.data!.docs;

          if (_searchTerm.isNotEmpty) {
            words = words.where((doc) {
              return doc['word'].toString().toLowerCase().contains(_searchTerm.toLowerCase());
            }).toList();
          }
          // 단어 목록이 비어 있을 때 메시지 표시
          if (words.isEmpty) {
            return const Center(child: Text('추가된 단어가 없습니다. 새로운 단어를 추가해보세요!'));
          }

          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              var word = words[index];
              return ListTile(
                title: Text(word['word']),
                subtitle: Text(word['meaning']),

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
