import 'dart:math';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'vocabulary_service.dart';

class LearningMode extends StatefulWidget {
  final bool studyEnglish; // 영어 공부 모드 여부
  final String vocabularyId; // 선택한 단어장 ID

  const LearningMode({
    Key? key,
    required this.studyEnglish,
    required this.vocabularyId,
  }) : super(key: key);

  @override
  _LearningModeState createState() => _LearningModeState();
}

class _LearningModeState extends State<LearningMode> {
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Map<String, String>> wordsList = [];

  final TextEditingController _inputController = TextEditingController();
  String _currentWord = ''; // 현재 단어
  String _currentMeaning = ''; // 현재 단어의 의미
  bool? _isCorrect; // 정답여부
  int _currentWordIndex = 0; // 현재 단어 인덱스
  int _lives = 3; // 목숨 수
  bool _gameOver = false; // 게임오버
  int _moneyEarned = 0; // 획득한 돈
  int correctWords = 0;
  int incorrectWords = 0;

  @override
  void initState() {
    super.initState();
    fetchWords();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // 다음 단어 로드
  void _loadNextWord() {
    setState(() {
      if (_lives > 0 && _currentWordIndex < wordsList.length) {
        _currentWord = widget.studyEnglish
            ? wordsList[_currentWordIndex]['word']!
            : wordsList[_currentWordIndex]['meaning']!;
        _currentMeaning = widget.studyEnglish
            ? wordsList[_currentWordIndex]['meaning']!
            : wordsList[_currentWordIndex]['word']!;
        _isCorrect = null; // 다음 문제로 넘어갈 때 표시되지 않도록 null로 초기화
        _inputController.clear();
        _currentWordIndex++;
      } else if (!_gameOver) {
        _gameOver = true; // 게임오버됨
        _showGameOverDialog(); // 게임 결과 화면 표시
      }
    });
  }

  // 정답 확인 함수
  void _checkAnswer() {
    setState(() {
      String userInput = _inputController.text.trim();
      _isCorrect = userInput == _currentMeaning;

      if (_isCorrect == false) {
        // 틀리면 목숨 줄임
        incorrectWords++;
        _lives--;

        if (_lives == 0) {
          // 목숨이 더 이상 없으면 게임 끝냄
          _gameOver = true;
          _showGameOverDialog();
        }
      } else {
        correctWords++;
        _moneyEarned += 10;
      }
    });
  }

  void _showGameOverDialog() {
    int totalWords = wordsList.length;
    double accuracyRate = correctWords / totalWords * 100;
    _moneyEarned += _lives * wordsList.length * 5;

    const textStyle = TextStyle(fontSize: 18);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게임 종료'),
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                Text('총 단어 수: $totalWords', style: textStyle),
                Text('맞은 단어 수: $correctWords', style: textStyle),
                Text('틀린 단어 수: $incorrectWords', style: textStyle),
                Text('정답률: $accuracyRate%', style: textStyle),
                Text('남은 목숨 수: $_lives', style: textStyle),
                Text('획득한 돈: $_moneyEarned', style: textStyle),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateUserMoneyInFirebase();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchWords() async {
    final VocabularyService vocabService = VocabularyService();
    final words =
        await vocabService.getWordsFromVocabulary(widget.vocabularyId);

    // 단어 목록을 랜덤하게 섞기
    final random = Random();
    words.shuffle(random);

    setState(() {
      wordsList = words.map((word) => convertToMapStringString(word)).toList();
    });

    _loadNextWord(); // 단어를 불러온 후 첫 번째 단어로 초기화
  }

  Map<String, String> convertToMapStringString(Map<String, dynamic> word) {
    return {
      'word': word['word'] ?? '',
      'meaning': word['meaning'] ?? '',
    };
  }

  void showModeSelectionDialog(
      void Function(bool studyEnglish) navigateToMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('모드 선택'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // 의미 공부 모드 선택
                  Navigator.of(context).pop();
                  navigateToMode(true);
                },
                child: const Text('의미 공부'),
              ),
              const SizedBox(width: 16),
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

  void _updateUserMoneyInFirebase() async {
    String uid = 'abc';
    if (auth.currentUser != null) {
      uid = auth.currentUser!.email.toString();
    }

    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.collection("users").doc(uid);

    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
    int m = documentSnapshot.get('money');
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"money": m + _moneyEarned});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 모드'),
        backgroundColor: Colors.purple,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    _currentWord,
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 30),
                  // 단어 입력 필드
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText:
                            widget.studyEnglish ? '의미를 입력하세요' : '영어 단어를 입력하세요',
                      ),
                      onSubmitted: (_) {
                        _checkAnswer(); // 정답 확인

                        // 피드백을 보여줄 SnackBar 표시
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: _isCorrect == true
                                ? const Text('정답입니다!')
                                : const Text('틀렸습니다.'),
                            duration: const Duration(seconds: 3), // 표시 시간 조절
                          ),
                        );
                        _loadNextWord(); // 다음 문제로 넘어감
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Lives indicator in the top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              children: List.generate(
                _lives,
                (index) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.favorite, color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
