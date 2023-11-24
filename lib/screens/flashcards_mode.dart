import 'dart:math';

import 'package:flutter/material.dart';
import 'vocabulary_service.dart';

class FlashcardsMode extends StatefulWidget {
  final bool studyEnglish; // 영어 공부 모드 여부
  final String vocabularyId; // 선택한 단어장 ID

  const FlashcardsMode(
      {Key? key, required this.studyEnglish, required this.vocabularyId})
      : super(key: key);

  @override
  _FlashcardsModeState createState() => _FlashcardsModeState();
}

class _FlashcardsModeState extends State<FlashcardsMode> {
  List<Map<String, String>> flashcards = [];

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
  void initState() {
    super.initState();
    fetchFlashcards();
  }

  Future<void> fetchFlashcards() async {
    final VocabularyService vocabService = VocabularyService();
    final words =
        await vocabService.getWordsFromVocabulary(widget.vocabularyId);

    // 단어 목록을 랜덤하게 섞기
    final random = Random();
    words.shuffle(random);

    setState(() {
      flashcards = words.map((word) => convertToMapStringString(word)).toList();
    });
  }

  Map<String, String> convertToMapStringString(Map<String, dynamic> word) {
    return {
      'word': word['word'] ?? '',
      'meaning': word['meaning'] ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = flashcards.isNotEmpty
        ? flashcards[currentIndex]
        : {'word': '', 'meaning': ''};

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
