import 'package:flutter/material.dart';

class LearningMode extends StatefulWidget {
  const LearningMode({Key? key}) : super(key: key);

  @override
  _LearningModeState createState() => _LearningModeState();
}

class _LearningModeState extends State<LearningMode> {
  // 예시 단어 목록
  final List<Map<String, String>> exampleWords = [
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
  ];

  final TextEditingController _inputController = TextEditingController();
  String _currentWord = ''; // 현재 단어
  String _currentMeaning = ''; // 현재 단어의 의미
  bool? _isCorrect;

  int _currentWordIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNextWord();
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
        _currentWord = exampleWords[_currentWordIndex]['word']!;
        _currentMeaning = exampleWords[_currentWordIndex]['meaning']!;
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '의미를 입력하세요',
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
