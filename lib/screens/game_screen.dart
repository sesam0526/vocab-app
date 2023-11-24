import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'flashcards_mode.dart';
import 'multiplechoice_mode.dart';
import 'learning_mode.dart';
import 'vocabulary_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final buttonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: Colors.purple, // 글자색
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), // 버튼 패딩
    textStyle: const TextStyle(
      fontSize: 18, // 글자 크기
    ),
    minimumSize: const Size(300, 0), // 버튼의 최소 크기 (가로 폭)
  );

  final List<Map<String, String>> gameModes = [
    {
      'name': '플래시카드 모드',
      'description': '플래시카드 모드에 대한 설명입니다.',
    },
    {
      'name': '4지선다 모드',
      'description': '4지선다 모드에 대한 설명입니다.',
    },
    {
      'name': '학습 모드',
      'description': '학습 모드에 대한 설명입니다.',
    },
  ];

  int currentPage = 0;

  void _showModeDescription(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(gameModes[index]['name']!),
          content: Text(gameModes[index]['description']!),
          actions: [
            if (index > 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    currentPage--;
                  });
                  Navigator.of(context).pop();
                  _showModeDescription(currentPage);
                },
                child: const Icon(Icons.arrow_back), // 이전 아이콘
              ),
            if (index < gameModes.length - 1)
              TextButton(
                onPressed: () {
                  setState(() {
                    currentPage++;
                  });
                  Navigator.of(context).pop();
                  _showModeDescription(currentPage);
                },
                child: const Icon(Icons.arrow_forward), // 다음 아이콘
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showVocabularySelectionDialog(
      void Function(String vocabularyId, bool studyEnglish)
          navigateToMode) async {
    final VocabularyService vocabService = VocabularyService();

    final List<DocumentSnapshot> vocabularyBooks =
        await vocabService.getVocabularyBooks();

    // 선택 가능한 단어장이 없는 경우
    if (vocabularyBooks.isEmpty) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text('선택 가능한 단어장이 없습니다. 단어장을 먼저 만들어주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('단어장 선택'),
          content: SingleChildScrollView(
            child: ListBody(
              children: vocabularyBooks.map((vocabulary) {
                return ListTile(
                  title: Text(vocabulary['name'] ?? ''),
                  onTap: () async {
                    final List<Map<String, dynamic>> words = await vocabService
                        .getWordsFromVocabulary(vocabulary.id);

                    if (words.isEmpty) {
                      // 선택한 단어장에 단어가 존재하지 않을 경우
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('알림'),
                            content: const Text(
                                '선택한 단어장에 단어가 존재하지 않습니다. 단어를 추가해주세요.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      showModeSelectionDialog((studyEnglish) async {
                        // 모드 선택 팝업 표시
                        String vocabularyId = vocabulary.id ?? '';
                        navigateToMode(vocabularyId, studyEnglish);
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void showModeSelectionDialog(
      void Function(bool studyEnglish) navigateToMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('모드 선택'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
            children: [
              ElevatedButton(
                onPressed: () {
                  // 의미 공부 모드 선택
                  Navigator.of(context).pop();
                  navigateToMode(true);
                },
                child: const Text('의미 공부'),
              ),
              const SizedBox(width: 16), // 버튼 사이의 간격 조절
              ElevatedButton(
                onPressed: () {
                  // 영단어 공부 모드 선택
                  Navigator.of(context).pop();
                  navigateToMode(false);
                },
                child: const Text('영단어 공부'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게임'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            onPressed: () async {
              // 게임 설명서 팝업 표시
              _showModeDescription(currentPage);
            },
            icon: const Icon(Icons.book),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // 단어장 선택 팝업 표시
                  showVocabularySelectionDialog(
                      (vocabularyId, studyEnglish) async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardsMode(
                            studyEnglish: studyEnglish,
                            vocabularyId: vocabularyId),
                      ),
                    );
                  });
                },
                style: buttonStyle,
                child: const Text('플래시카드 모드'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MultipleChoiceMode(),
                    ),
                  );
                },
                style: buttonStyle,
                child: const Text('4지선다 모드'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  showVocabularySelectionDialog(
                      (vocabularyId, studyEnglish) async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LearningMode(
                            studyEnglish: studyEnglish,
                            vocabularyId: vocabularyId),
                      ),
                    );
                  });
                },
                style: buttonStyle,
                child: const Text('학습 모드'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
