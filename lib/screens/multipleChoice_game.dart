import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/utils/game_utils.dart';
import 'store_service.dart';

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
  final StoreService _storeService = StoreService();
  // 버튼 스타일 지정
  final buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
    textStyle: const TextStyle(
      fontSize: 22, // 글자 크기
    ),
    minimumSize: const Size(300, 0), // 버튼의 최소 크기 (가로 폭)
  );

  @override
  void initState() {
    // StatefulWidget이 생성될 때 호출
    super.initState(); // 초기에 데이터를 불러와서 화면에 표시
    initializeGame();
  }

  List<Map<String, String>> wordsList = []; // 단어 리스트

  int currentWordIndex = 0; // 현재 문제 인덱스
  int lives = 1; // 목숨 수

  // 단어 가져오기
  Future<void> initializeGame() async {
    wordsList = await GameUtils.fetchWords(widget.vocabularyId);
    int fetchedLives =
        await _storeService.getUserLives(); // Firestore에서 Lives 개수 가져오기
    setState(() {
      lives = lives + fetchedLives; // Lives 개수 업데이트
    });
  }

// 다음 문제 가져옴
  void loadNextQuestion() {
    setState(() {
      if (lives > 0 && currentWordIndex < wordsList.length - 1) {
        // 목숨이 남아있고, 문제가 아직 남았으면
        currentWordIndex++; // 현재 단어 인덱스 올림
      } else {
        // 목숨이 없거나, 문제를 다 풀면
        showGameOverDialog(); // 게임 결과 화면 표시
      }
    });
  }

  int correctWords = 0; // 맞은 단어 수
  int incorrectWords = 0; // 틀린 단어 수
  int scoreReceived = 0; // 받은 점수
  int moneyEarned = 0; // 획득한 돈

// 사용자가 선택한 선택지에 대해 정답 확인하는 함수
  void checkAnswer(String selectedOption) {
    setState(() {
      String correctOption = widget.studyEnglish // 공부 모드에 따른 답
          ? wordsList[currentWordIndex]['word']!
          : wordsList[currentWordIndex]['meaning']!;

      if (selectedOption == correctOption) {
        // 사용자가 선택한 선택지가 맞으면 돈과 점수 획득
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
        addToWrongWordsList(); // 오답 노트에 추가
        showSnackBar('틀렸습니다.');

        if (lives == 0) {
          // 목숨이 더 이상 없으면 게임 끝냄
          showGameOverDialog();
        }
      }
      loadNextQuestion(); // 다음 문제로 넘어감
    });
  }

  // 오답 노트 관련 코드 추가
  void addToWrongWordsList() async {
    String uid = 'abc'; // 사용자의 UID 또는 이메일로 변경
    FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser != null) {
      uid = auth.currentUser!.email.toString();
    }

    String vocabularyId = widget.vocabularyId;
    String word = wordsList[currentWordIndex]['word']!;
    String meaning = wordsList[currentWordIndex]['meaning']!;

    // 오답 노트에 추가
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("Vocabularies")
        .doc(vocabularyId)
        .collection("WrongWords")
        .doc(word) // 단어를 문서 ID로 사용하여 중복된 단어를 덮어쓰지 않도록 함
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        // 이미 해당 단어가 오답 노트에 존재할 경우, incorrectCount를 1 증가시키기
        int currentIncorrectCount = docSnapshot['incorrectCount'] ?? 0;
        docSnapshot.reference
            .update({'incorrectCount': currentIncorrectCount + 1});
      } else {
        // 해당 단어가 오답 노트에 존재하지 않을 경우, 새로운 문서로 추가
        FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("Vocabularies")
            .doc(vocabularyId)
            .collection("WrongWords")
            .doc(word)
            .set({
          'word': word,
          'meaning': meaning,
          'incorrectCount': 1, // 처음 틀렸으니 1로 설정
        });
      }
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
          ? wordsList[currentWordIndex]['word']!
          : wordsList[currentWordIndex]['meaning']!,
    ];

    // 정답 선택지 제외한 나머지 단어들 가져옴
    List<Map<String, String>> remainingOptions = List.from(wordsList);
    remainingOptions.removeAt(currentWordIndex); // 정답 선택지 제외
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
        backgroundColor: Colors.purple[400],
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
                        ? wordsList[currentWordIndex]['meaning']!
                        : wordsList[currentWordIndex]['word']!,
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
                          checkAnswer(option);
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
