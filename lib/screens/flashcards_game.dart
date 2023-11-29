import 'package:flutter/material.dart';
import 'package:flutter_project/utils/game_utils.dart';

class FlashcardsGame extends StatefulWidget {
  final bool studyEnglish; // 영단어 공부 모드 여부
  final String vocabularyId; // 선택한 단어장 ID

  const FlashcardsGame(
      {Key? key, required this.studyEnglish, required this.vocabularyId})
      : super(key: key);

  @override
  _FlashcardsGameState createState() => _FlashcardsGameState();
}

class _FlashcardsGameState extends State<FlashcardsGame> {
  List<Map<String, String>> wordsList = []; // 플래시카드 리스트

  @override
  void initState() {
    // StatefulWidget이 생성될 때 호출
    super.initState(); // 초기에 데이터를 불러와서 화면에 표시
    initializeGame();
  }

// 단어 가져오기
  Future<void> initializeGame() async {
    wordsList = await GameUtils.fetchWords(widget.vocabularyId);
    setState(() {});
  }

  int currentWordIndex = 0;
  bool showAnswer = false;

  bool get hasPrevFlashcard => currentWordIndex > 0;
  bool get hasNextFlashcard => currentWordIndex < wordsList.length - 1;

// 다음 단어 보여주는 함수
  void showNextFlashcard() {
    if (hasNextFlashcard) {
      setState(() {
        currentWordIndex++;
        showAnswer = false;
      });
    }
  }

// 이전 단어 보여주는 함수
  void showPrevFlashcard() {
    if (hasPrevFlashcard) {
      setState(() {
        currentWordIndex--;
        showAnswer = false;
      });
    }
  }

// 정답 보이게 하거나 안 보이게 하는 함수
  void toggleAnswer() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = wordsList.isNotEmpty // wordsList 리스트가 비어있지 않으면
        ? wordsList[currentWordIndex]
        : {
            'word': '',
            'meaning': ''
          }; // currentWordIndex에 해당하는 위치의 플래시카드를 flashcard 변수에 할당

    return Scaffold(
      appBar: AppBar(
        title: const Text('플래시카드 모드'),
        backgroundColor: Colors.purple[400],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 120,
              ),
              Text(
                widget.studyEnglish // // 공부 모드에 따른 문제 표시
                    ? flashcard['meaning']!
                    : flashcard['word']!,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(
                height: 20,
              ),
              if (showAnswer) // 정답 보기 버튼을 누르면
                Text(
                  widget.studyEnglish // 공부 모드에 따른 답 표시
                      ? flashcard['word']!
                      : flashcard['meaning']!,
                  style: const TextStyle(fontSize: 56),
                ),
              ElevatedButton(
                onPressed: toggleAnswer, // 버튼을 누르면 showAnswer 변수가 토글됨
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                ), // 정답 보기 버튼을 누르면 정답이 보이고 닫기 버튼으로 다시 정답을 안 볼 수 있음
                child: Text(showAnswer ? '닫기' : '정답 보기'),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasPrevFlashcard)
                    ElevatedButton(
                      onPressed: showPrevFlashcard,
                      child: const Icon(Icons.arrow_back), // 이전 아이콘
                    ),
                  const SizedBox(
                    width: 20,
                  ),
                  if (hasNextFlashcard)
                    ElevatedButton(
                      onPressed: showNextFlashcard,
                      child: const Icon(Icons.arrow_forward), // 다음 아이콘
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
