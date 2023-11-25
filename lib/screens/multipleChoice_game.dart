import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'vocabulary_service.dart';

class MultipleChoiceGame extends StatefulWidget {
  final bool studyEnglish; // 영단어 공부 모드 여부
  final String vocabularyId; // 선택한 단어장 ID

  const MultipleChoiceGame({
    Key? key,
    required this.studyEnglish,
    required this.vocabularyId,
  }) : super(key: key);

  @override
  _MultipleChoiceGameState createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceGame> {
  // 버튼 스타일 지정
  final buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
    textStyle: const TextStyle(
      fontSize: 22, // 글자 크기
    ),
    minimumSize: const Size(300, 0), // 버튼의 최소 크기 (가로 폭)
  );

  List<Map<String, String>> wordsList = [];
  int _currentWordIndex = 0; // 현재 문제 인덱스
  int _moneyEarned = 0; // 획득한 돈
  int _lives = 3; // 목숨 수
  int correctWords = 0; // 맞은 단어 수
  int incorrectWords = 0; // 틀린 단어 수

  @override
  void initState() {
    // StatefulWidget이 생성될 때 호출
    super.initState(); // 초기에 데이터를 불러와서 화면에 표시
    fetchWords();
  }

// 단어 가져오는 함수
  Future<void> fetchWords() async {
    final VocabularyService vocabService = VocabularyService();
    final words = await vocabService
        .getWordsFromVocabulary(widget.vocabularyId); // 선택한 단어장에서 단어 목록 가져옴

    // 단어 목록을 랜덤하게 섞기
    final random = Random();
    words.shuffle(random);

    setState(() {
      wordsList = words.toList(); // wordsList 리스트에 저장
    });
  }

// 다음 문제 가져옴
  void _loadNextQuestion() {
    setState(() {
      if (_lives > 0 && _currentWordIndex < wordsList.length - 1) {
        // 목숨이 남아있고, 문제가 아직 남았으면
        _currentWordIndex++; // 현재 단어 인덱스 올림
      } else {
        // 목숨이 없거나, 문제를 다 풀면
        _showGameOverDialog(); // 게임 결과 화면 표시
      }
    });
  }

// 사용자가 선택한 선택지에 대해 정답 확인하는 함수
  void _checkAnswer(String selectedOption) {
    setState(() {
      String correctOption = widget.studyEnglish // 공부 모드에 따른 답
          ? wordsList[_currentWordIndex]['word']!
          : wordsList[_currentWordIndex]['meaning']!;

      if (selectedOption == correctOption) {
        // 사용자가 선택한 선택지가 맞으면 돈 획득
        correctWords++;
        _moneyEarned += 10;
        _showSnackBar('정답입니다!');
      } else {
        // 틀리면 목숨 줄임
        incorrectWords++;
        _lives--;
        _showSnackBar('틀렸습니다.');

        if (_lives == 0) {
          // 목숨이 더 이상 없으면 게임 끝냄
          _showGameOverDialog();
        }
      }
      _loadNextQuestion(); // 다음 문제로 넘어감
    });
  }

// 피드백을 보여줄 SnackBar 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), // 메시지 출력
        duration: const Duration(seconds: 1), // 표시 시간 조절
      ),
    );
  }

// 게임 결과 화면 함수
  void _showGameOverDialog() {
    int totalWords = wordsList.length; // 전체 단어 수
    double accuracyRate = correctWords / totalWords * 100; // 정답률
    _moneyEarned += _lives * wordsList.length * 5; // 획득한 돈

    const textStyle = TextStyle(fontSize: 18); // 글자 스타일
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
                Text('정답률: ${accuracyRate.toStringAsFixed(2)}%',
                    style: textStyle), // 반올림해서 소수점 둘째자리까지 표현
                Text('남은 목숨 수: $_lives', style: textStyle),
                Text('획득한 돈: $_moneyEarned', style: textStyle),
              ],
            ),
          ),
          actions: [
            TextButton(
              // 닫기 버튼을 누르면
              onPressed: () {
                _updateUserMoneyInFirebase(); // 파이어베이스에 유저 돈 업데이트
                Navigator.of(context).pop(); // 다이얼로그 닫힘
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

// 파이버베이스에 유저 돈 업데이트하는 함수
  void _updateUserMoneyInFirebase() async {
    FirebaseAuth auth = FirebaseAuth.instance; // 사용자 인증관련 작업 수행
    String uid = 'abc'; // 사용자 uid

    if (auth.currentUser != null) {
      // 현재 사용자가 인증되어 있으면
      uid = auth.currentUser!.email.toString(); // 사용자의 이메일을 UID로 사용
    }

    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance
            .collection("users")
            .doc(uid); // 특정 사용자의 문서에 접근

    // Firestore에서 해당 문서를 가져와 DocumentSnapshot 객체로 저장
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();

    // 현재 사용자의 돈 정보를 DocumentSnapshot에서 가져와 변수 m에 저장
    int m = documentSnapshot.get('money');

    // 현재 돈에 _moneyEarned를 더하여 새로운 돈 값으로 사용자 돈을 업데이트
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"money": m + _moneyEarned});
  }

  @override
  Widget build(BuildContext context) {
    if (wordsList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('4지선다 모드'),
          backgroundColor: Colors.purple,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 정답 선택지 가져옴
    List<String> options = [
      widget.studyEnglish
          ? wordsList[_currentWordIndex]['word']!
          : wordsList[_currentWordIndex]['meaning']!,
    ];

    // 정답 선택지 제외한 나머지 단어들 가져옴
    List<Map<String, String>> remainingOptions = List.from(wordsList);
    remainingOptions.removeAt(_currentWordIndex); // 정답 선택지 제외
    remainingOptions.shuffle();

    // 리스트에 정답 제외한 랜덤 선택지 3개 추가해서 총 선택지 4개 만듦
    options.addAll(remainingOptions.sublist(0, 3).map((option) =>
        widget.studyEnglish ? option['word']! : option['meaning']!));

    // 단어 목록을 랜덤하게 섞기
    final random = Random();
    options.shuffle(random);

    return Scaffold(
      appBar: AppBar(
        title: const Text('4지선다 모드'),
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
                    widget.studyEnglish
                        ? wordsList[_currentWordIndex]['meaning']!
                        : wordsList[_currentWordIndex]['word']!,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 30),
                  // 리스트의 각 요소에 대해 주어진 함수를 실행하고, 그 결과로 나오는 모든 요소를 단일 리스트로 펼침
                  ...options.expand((option) {
                    return [
                      ElevatedButton(
                        // 버튼으로 각 선택지 표시
                        onPressed: () {
                          // 유저가 선택한 선택지의 답 확인
                          _checkAnswer(option);
                        },
                        style: buttonStyle,
                        child: Text(option),
                      ),
                      const SizedBox(height: 10),
                    ];
                  }).toList(), // 각 선택지에 대한 위젯들이 모두 단일 리스트로 합쳐져 화면에 표시
                ],
              ),
            ),
          ),
          // body의 상단오른쪽에 목숨 표시
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
