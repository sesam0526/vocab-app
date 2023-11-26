import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_project/utils/game_utils.dart';
import 'store_service.dart';

class LearningGame extends StatefulWidget {
  final bool studyEnglish; // 영단어 공부 모드 여부
  final String vocabularyId; // 선택한 단어장 ID

  const LearningGame({
    Key? key,
    required this.studyEnglish,
    required this.vocabularyId,
  }) : super(key: key);

  @override
  _LearningGameState createState() => _LearningGameState();
}

class _LearningGameState extends State<LearningGame> {
  final StoreService _storeService = StoreService();

  final TextEditingController inputController =
      TextEditingController(); // 텍스트 입력 필드

  @override
  void initState() {
    // StatefulWidget이 생성될 때 호출
    super.initState(); // 초기에 데이터를 불러와서 화면에 표시
    initializeGame();
  }

  @override
  void dispose() {
    // StatefulWidget이 제거될 때 호출
    inputController.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  List<Map<String, String>> wordsList = []; // 단어 리스트

  int currentWordIndex = 0; // 현재 단어 인덱스
  String currentQuestion = ''; // 현재 단어
  String currentAnswer = ''; // 현재 단어의 의미

  bool? isCorrect; // 정답여부
  int lives = 0; // 목숨 수

// 단어 가져오기
  Future<void> initializeGame() async {
    wordsList = await GameUtils.fetchWords(widget.vocabularyId);
    int fetchedLives =
        await _storeService.getUserLives(); // Firestore에서 Lives 개수 가져오기
    loadNextQuestion();
    setState(() {
      lives = fetchedLives; // Lives 개수 업데이트
    });
  }

  // 다음 문제 가져옴
  void loadNextQuestion() {
    setState(() {
      if (lives > 0 && currentWordIndex < wordsList.length) {
        // 목숨이 남아있고, 문제가 아직 남았으면
        currentQuestion = widget.studyEnglish // 공부 모드에 따른 문제
            ? wordsList[currentWordIndex]['meaning']!
            : wordsList[currentWordIndex]['word']!;
        currentAnswer = widget.studyEnglish // 공부 모드에 따른 답
            ? wordsList[currentWordIndex]['word']!
            : wordsList[currentWordIndex]['meaning']!;
        isCorrect = null; // 다음 문제로 넘어갈 때 표시되지 않도록 null로 초기화
        inputController.clear(); // 텍스트 입력 필드 내용 지움
        currentWordIndex++; // 현재 단어 인덱스 올림
      } else {
        // 목숨이 없거나, 문제를 다 풀면
        showGameOverDialog(); // 게임 결과 화면 표시
      }

      if (isCorrect == false) {
        // 문제를 틀렸을 때만 오답 노트 업데이트
        GameUtils.addToWrongWordsList(
            widget.vocabularyId, wordsList[currentWordIndex - 1]);
      }
    });
  }

  int correctWords = 0; // 맞은 단어 수
  int incorrectWords = 0; // 틀린 단어 수
  int scoreReceived = 0; // 받은 점수
  int moneyEarned = 0; // 획득한 돈

  // 정답 확인 함수
  void checkAnswer() {
    setState(() {
      String userInput =
          inputController.text.trim(); // 사용자가 입력한 텍스트 문자열 앞뒤의 공백을 제거
      isCorrect =
          (userInput == currentAnswer); // 사용자 입력과 현재 정답 비교해서 _isCorrect 변수에 할당

      if (isCorrect == true) {
        // 사용자가 입력한 정답이 맞으면 돈과 점수 획득
        correctWords++;
        moneyEarned += 10;
        scoreReceived += 10;
        showSnackBar('정답입니다!');
      } else {
        // 틀리면 목숨과 점수 잃음
        incorrectWords++;
        scoreReceived -= 10;
        _storeService.subtractLives(1); // DB에서 목숨 차감
        lives--;
        showSnackBar('틀렸습니다.');

        if (lives == 0) {
          // 목숨이 더 이상 없으면 게임 끝냄
          showGameOverDialog();
        }
      }
      loadNextQuestion(); // 다음 문제로 넘어감
    });
  }

// 피드백을 보여줄 SnackBar 표시
  void showSnackBar(String message) {
    GameUtils.showSnackBar(context, message);
  }

// 게임 결과 화면 함수
  void showGameOverDialog() {
    int totalWords = wordsList.length; // 전체 단어 수
    double accuracyRate = correctWords / totalWords * 100; // 정답률
    scoreReceived += lives * wordsList.length * 5; // 받은 점수
    moneyEarned += lives * wordsList.length * 5; // 획득한 돈

    GameUtils.updateScoreAndMoneyInFirebase(
        scoreReceived, moneyEarned); // 파이어베이스에 유저 점수와 돈 업데이트

    GameUtils.showGameOverDialog(
        context,
        totalWords,
        correctWords,
        incorrectWords,
        accuracyRate,
        lives,
        scoreReceived,
        moneyEarned); // 게임 결과 화면 표시
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 모드'),
        backgroundColor: Colors.purple[400],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    currentQuestion,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 30),
                  // 단어 입력 필드
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      style: const TextStyle(fontSize: 20),
                      controller: inputController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: widget.studyEnglish
                            ? '영단어를 입력하세요'
                            : '의미를 입력하세요', // 텍스트 필드에 안내
                      ),
                      onSubmitted: (_) {
                        // 엔터를 누르면
                        checkAnswer(); // 정답 확인
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    // 확인 버튼을 누르면
                    onPressed: checkAnswer, // 정답 확인
                    child: const Text('확인'),
                  ),
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
                lives,
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
