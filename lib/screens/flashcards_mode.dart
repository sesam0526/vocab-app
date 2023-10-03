import 'package:flutter/material.dart';

class FlashcardsMode extends StatefulWidget {
  final bool studyEnglish; // 영어 공부 모드 여부

  const FlashcardsMode({Key? key, required this.studyEnglish})
      : super(key: key);

  @override
  _FlashcardsModeState createState() => _FlashcardsModeState();
}

class _FlashcardsModeState extends State<FlashcardsMode> {
  List<Map<String, String>> flashcards = [
    {
      'word': 'Apple',
      'meaning': '사과',
    },
    {
      'word': 'Banana',
      'meaning': '바나나',
    },
    {
      'word': 'Carrot',
      'meaning': '당근',
    },
    // 추가 단어와 의미를 필요한 만큼 여기에 추가하세요.
  ];

  int currentIndex = 0;
  bool showMeaning = false;

  bool get hasPrevFlashcard => currentIndex > 0;
  bool get hasNextFlashcard => currentIndex < flashcards.length - 1;

  void showNextFlashcard() {
    if (hasNextFlashcard) {
      setState(() {
        currentIndex++;
        showMeaning = false;
      });
    }
  }

  void showPrevFlashcard() {
    if (hasPrevFlashcard) {
      setState(() {
        currentIndex--;
        showMeaning = false;
      });
    }
  }

  void toggleMeaning() {
    setState(() {
      showMeaning = !showMeaning;
    });
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = flashcards[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('플래시카드 모드'),
        backgroundColor: Colors.purple,
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
                widget.studyEnglish
                    ? flashcard['word']!
                    : flashcard['meaning']!,
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(
                height: 20,
              ),
              if (showMeaning)
                Text(
                  widget.studyEnglish
                      ? flashcard['meaning']!
                      : flashcard['word']!,
                  style: const TextStyle(fontSize: 56),
                ),
              ElevatedButton(
                onPressed: toggleMeaning,
                child: Text(showMeaning ? '닫기' : '의미 보기'),
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
