import 'package:flutter/material.dart';

import 'vocabulary_service.dart';

class LearningMode extends StatefulWidget {
  final bool studyEnglish; // 영어 공부 모드 여부
  final String vocabularyId; // 추가: 선택한 단어장 ID

  const LearningMode({
    Key? key,
    required this.studyEnglish,
    required this.vocabularyId,
  }) : super(key: key);

  @override
  _LearningModeState createState() => _LearningModeState();
}

class _LearningModeState extends State<LearningMode> {
  // 예시 단어 목록
  List<Map<String, String>> exampleWords = [];

  final TextEditingController _inputController = TextEditingController();
  String _currentWord = ''; // 현재 단어
  String _currentMeaning = ''; // 현재 단어의 의미
  bool? _isCorrect;

  int _currentWordIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchWords(); // 변경: fetchFlashcards() -> fetchWords()
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // 다음 단어 로드
  void _loadNextWord() {
    setState(() {
      if (_currentWordIndex < exampleWords.length) {
        _currentWord = widget.studyEnglish
            ? exampleWords[_currentWordIndex]['word']!
            : exampleWords[_currentWordIndex]['meaning']!;
        _currentMeaning = widget.studyEnglish
            ? exampleWords[_currentWordIndex]['meaning']!
            : exampleWords[_currentWordIndex]['word']!;
        _isCorrect = null; // 다음 문제로 넘어갈 때 표시되지 않도록 null로 초기화
        _inputController.clear();
        _currentWordIndex++;
      } else {
        // 결과 표시 추가
        // 현재는 단순히 처음 단어로 돌아감
        _currentWordIndex = 0;
        _loadNextWord();
      }
    });
  }

  // 정답 확인 함수
  void _checkAnswer() {
    setState(() {
      String userInput = _inputController.text.trim();
      _isCorrect = userInput == _currentMeaning;
    });
  }

  Future<void> fetchWords() async {
    // 변경: vocabulary_service.dart에 대한 의존성 추가
    final VocabularyService vocabService = VocabularyService();
    final words =
        await vocabService.getWordsFromVocabulary(widget.vocabularyId);

    setState(() {
      exampleWords =
          words.map((word) => convertToMapStringString(word)).toList();
    });

    _loadNextWord(); // 변경: 단어를 불러온 후 첫 번째 단어로 초기화
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 모드'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
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
                    _checkAnswer(); // 엔터 키로 정답 확인
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _checkAnswer,
                child: const Text('정답 확인'),
              ),
              const SizedBox(height: 20),
              if (_isCorrect == true)
                const Text(
                  '정답입니다!',
                  style: TextStyle(fontSize: 18, color: Colors.green),
                )
              else if (_isCorrect == false)
                const Text(
                  '틀렸습니다.',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadNextWord,
                child: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
