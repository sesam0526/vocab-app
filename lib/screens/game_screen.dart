import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'flashcards_game.dart';
import 'multipleChoice_game.dart';
import 'learning_game.dart';
import 'vocabulary_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // 버튼 스타일 지정
  final buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32), // 버튼 패딩
    textStyle: const TextStyle(
      fontSize: 22, // 글자 크기
    ),
    minimumSize: const Size(300, 0), // 버튼의 최소 크기 (가로 폭)
  );

// 게임 설명서 리스트
  final List<Map<String, String>> gameManuals = [
    {
      'name': '게임 흐름',
      'description': '''
**게임 흐름**
  1. 시작: 게임을 선택합니다.
  2. 단어장 선택 : 게임을 진행할 단어장을 선택합니다.
  3. 모드 선택: 의미 공부 또는 영단어 공부 중 하나를 선택합니다.
  4. 게임 진행: 게임을 진행합니다.
''',
    },
    {
      'name': '모드 선택',
      'description': '''
**의미 공부**
  - 목표: 주어진 영어 단어의 의미를 맞춥니다.
  - 진행 방법: 영단어가 표시되면 사용자는 해당 단어의 의미를 추측하며 학습합니다.

**영단어 공부**
  - 목표: 주어진 의미에 해당하는 영어 단어를 맞춥니다.
  - 진행 방법: 의미가 표시되면 사용자는 해당 의미에 맞는 영어 단어를 추측하며 학습합니다.
''',
    },
    {
      'name': '플래시카드 게임',
      'description': '''
**목표** 
  주어진 문제에 대한 정답을 추측하고 정답을 확인하면서 학습하는 게임입니다.

**진행 방법**
  1. 플래시카드 표시: 플래시카드가 표시되면 사용자는 주어진 문제에 대한 답을 추측합니다.
  2. 정답 확인: 정답을 확인합니다.
  3. 다음 문제로 이동: 오른쪽 화살표를 눌러 다음 단어를 진행합니다.
  4. 이전 문제로 이동: 왼쪽 화살표를 눌러 이전 단어를 진행합니다.
  5. 게임 종료: 뒤로 가기 버튼을 눌러 게임을 종료합니다.
''',
    },
    {
      'name': '4지선다 게임',
      'description': '''
**목표**
  주어진 문제에 대한 정답을 고르는 게임입니다.

**진행 방법**
  1. 주어진 문제(단어 또는 의미)를 확인합니다.
  2. 네 개의 선택지 중에서 올바른 정답을 고릅니다.
  3. 정답을 맞추면 돈을 획득하고 다음 문제로 넘어갑니다.
  4. 틀리면 목숨이 감소하며, 목숨이 없으면 게임이 종료됩니다.

**게임 화면**
  - 문제: 주어진 영어 단어 또는 의미
  - 선택지: 네 개의 옵션 중 하나를 선택
  - 목숨: 게임을 진행할 때마다 감소하며, 목숨이 모두 소진되면 게임이 종료됩니다.

**결과 화면**
  - 맞은 단어 수
  - 틀린 단어 수
  - 정답률
  - 남은 목숨 수
  - 획득한 돈

**게임 종료**
  - 게임이 종료되면 결과 화면이 표시됩니다.
  - 획득한 돈은 게임 결과에 따라 변동되며, 사용자의 계정에 자동으로 업데이트됩니다.
''',
    },
    {
      'name': '학습 게임',
      'description': '''
**목표**
  주어진 단어 또는 의미에 대한 정확한 정답을 입력하는 게임입니다.

**진행 방법**
  1. 주어진 문제(단어 또는 의미)를 확인합니다.
  2. 텍스트 입력 필드에 정답을 입력합니다.
  3. 입력한 정답이 맞으면 다음 문제로 넘어갑니다.
  4. 입력한 정답이 틀리면 목숨이 감소하며, 목숨이 없으면 게임이 종료됩니다.

**게임 화면**
  - 문제: 주어진 영어 단어 또는 의미
  - 텍스트 입력 필드: 정답 입력을 위한 공간
  - 목숨: 게임을 진행할 때마다 감소하며, 목숨이 모두 소진되면 게임이 종료됩니다.

**정답 확인**
  - 정답을 입력하고 엔터를 누르거나, 확인 버튼을 눌러 정답을 확인할 수 있습니다.
  - 정답이 맞으면 돈을 획득하고 다음 문제로 넘어갑니다.

**결과 화면**
  - 맞은 단어 수
  - 틀린 단어 수
  - 정답률
  - 남은 목숨 수
  - 획득한 돈

**게임 종료**
  - 게임이 종료되면 결과 화면이 표시됩니다.
  - 획득한 돈은 게임 결과에 따라 변동되며, 사용자의 계정에 자동으로 업데이트됩니다.
''',
    },
  ];

  int currentPage = 0;
  // 게임 설명서 함수
  void _showGameManualDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(gameManuals[index]['name']!),
          content: SingleChildScrollView(
            // 스크롤 화면
            child: Text(gameManuals[index]['description']!),
          ),
          actions: [
            if (index > 0)
              TextButton(
                // 이전 화살표를 누르면 이전 설명서로 돌아감
                onPressed: () {
                  setState(() {
                    currentPage--;
                  });
                  Navigator.of(context).pop();
                  _showGameManualDialog(currentPage);
                },
                child: const Icon(Icons.arrow_back), // 이전 아이콘
              ),
            if (index < gameManuals.length - 1)
              TextButton(
                // 다음 화살표를 누르면 다음 설명서로 넘어감
                onPressed: () {
                  setState(() {
                    currentPage++;
                  });
                  Navigator.of(context).pop();
                  _showGameManualDialog(currentPage);
                },
                child: const Icon(Icons.arrow_forward), // 다음 아이콘
              ),
            TextButton(
              // 닫기 버튼을 누르면 다이얼로그 닫힘
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

// 단어장 선택 함수
  Future<void> showVocabularyBookSelectionDialog(
      void Function(String vocabularyId, bool studyEnglish)
          navigateToMode) async {
    final VocabularyService vocabService = VocabularyService();

    final List<DocumentSnapshot> vocabularyBooks =
        await vocabService.getVocabularyBooks();

    // 선택 가능한 단어장이 없는 경우 알림 다이얼로그 표시
    if (vocabularyBooks.isEmpty) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text(
              '선택 가능한 단어장이 없습니다. 단어장을 먼저 만들어주세요.',
            ),
            actions: [
              // 닫기 버튼을 누르면 알림 다이얼로그 닫힘
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
      return;
    }

// 단어장 선택하는 다이얼로그 표시
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
                      // 선택한 단어장에 단어가 존재하지 않을 경우 알림 다이얼로그 표시
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('알림'),
                            content: const Text(
                                '선택한 단어장에 단어가 존재하지 않습니다. 단어를 추가해주세요.'),
                            actions: [
                              // 닫기 버튼을 누르면 알림 다이얼로그 닫힘
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
                    } else {
                      // 단어가 존재하면
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      showModeSelectionDialog((studyEnglish) async {
                        // 모드 선택 다이얼로그 표시
                        String vocabularyId = vocabulary.id;
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

// 4지선다 게임을 위한 단어장 선택 함수
  Future<void> showVocabularyBookSelectionDialogInMultipleChoiceGame(
      void Function(String vocabularyId, bool studyEnglish)
          navigateToMode) async {
    final VocabularyService vocabService = VocabularyService();

    final List<DocumentSnapshot> vocabularyBooks =
        await vocabService.getVocabularyBooks();

    // 선택 가능한 단어장이 없는 경우 알림 다이얼로그 표시
    if (vocabularyBooks.isEmpty) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('알림'),
            content: const Text(
              '선택 가능한 단어장이 없습니다. 단어장을 먼저 만들어주세요.',
            ),
            actions: [
              // 닫기 버튼을 누르면 알림 다이얼로그 닫힘
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
      return;
    }

// 단어장 선택하는 다이얼로그 함수
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

                    if (words.length < 4) {
                      // 선택한 단어장에 단어가 4개 미만일 경우 알림 다이얼로그 표시
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('알림'),
                            content: const Text(
                                '선택한 게임에서는 4개 이상의 단어가 필요합니다. 단어를 추가해주세요.'),
                            actions: [
                              // 닫기 버튼을 누르면 알림 다이얼로그 닫힘
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
                    } else {
                      // 단어가 4개 이상이면
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      showModeSelectionDialog((studyEnglish) async {
                        // 모드 선택 다이얼로그 표시
                        String vocabularyId = vocabulary.id;
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

// 모드 선택 함수
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
                  navigateToMode(false);
                },
                child: const Text('의미 공부'),
              ),
              const SizedBox(width: 16), // 버튼 사이의 간격 조절
              ElevatedButton(
                onPressed: () {
                  // 영단어 공부 모드 선택
                  Navigator.of(context).pop();
                  navigateToMode(true);
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
              // 게임 설명서 다이얼로그 표시
              _showGameManualDialog(currentPage);
            },
            icon: const Icon(Icons.book),
          )
        ],
      ),
      body: SingleChildScrollView(
        // 스크롤 화면
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                // 플래시카드 게임 버튼을 누르면
                onPressed: () async {
                  // 단어장 선택 다이얼로그 표시
                  showVocabularyBookSelectionDialog(
                      (vocabularyId, studyEnglish) async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // 플래시카드 게임 화면으로 이동
                        builder: (context) => FlashcardsGame(
                            studyEnglish: studyEnglish,
                            vocabularyId: vocabularyId),
                      ),
                    );
                  });
                },
                style: buttonStyle,
                child: const Text('플래시카드 게임'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                // 4지선다 게임 버튼을 누르면
                onPressed: () async {
                  // 단어장 선택 다이얼로그 표시
                  showVocabularyBookSelectionDialogInMultipleChoiceGame(
                      (vocabularyId, studyEnglish) async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // 4지선다 게임 화면으로 이동
                        builder: (context) => MultipleChoiceGame(
                            studyEnglish: studyEnglish,
                            vocabularyId: vocabularyId),
                      ),
                    );
                  });
                },
                style: buttonStyle,
                child: const Text('4지선다 게임'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                // 학습 게임 버튼을 누르면
                onPressed: () async {
                  // 단어장 선택 다이얼로그 표시
                  showVocabularyBookSelectionDialog(
                      (vocabularyId, studyEnglish) async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // 학습 게임 화면으로 이동
                        builder: (context) => LearningGame(
                            studyEnglish: studyEnglish,
                            vocabularyId: vocabularyId),
                      ),
                    );
                  });
                },
                style: buttonStyle,
                child: const Text('학습 게임'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
