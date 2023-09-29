import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final buttonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: Colors.purple, // 글자색
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), // 버튼 패딩
    textStyle: const TextStyle(
      fontSize: 18, // 글자 크기
    ),
    minimumSize: const Size(300, 0), // 버튼의 최소 크기 (가로 폭)
  );

  final List<Map<String, String>> gameModes = [
    {
      'name': '플래시카드 모드',
      'description': '플래시카드 모드에 대한 설명입니다.',
    },
    {
      'name': '4지선다 모드',
      'description': '4지선다 모드에 대한 설명입니다.',
    },
    {
      'name': '학습 모드',
      'description': '학습 모드에 대한 설명입니다.',
    },
  ];

  int currentPage = 0;

  void _showModeDescription(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(gameModes[index]['name']!),
          content: Text(gameModes[index]['description']!),
          actions: [
            if (index > 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    currentPage--;
                  });
                  Navigator.of(context).pop();
                  _showModeDescription(currentPage);
                },
                child: const Icon(Icons.arrow_back), // 이전 아이콘
              ),
            if (index < gameModes.length - 1)
              TextButton(
                onPressed: () {
                  setState(() {
                    currentPage++;
                  });
                  Navigator.of(context).pop();
                  _showModeDescription(currentPage);
                },
                child: const Icon(Icons.arrow_forward), // 다음 아이콘
              ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게임'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            onPressed: () {
              // 게임 설명서 팝업 표시
              _showModeDescription(currentPage);
            },
            icon: const Icon(Icons.book),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  // 플래시카드 모드로 이동하는 코드 추가
                },
                style: buttonStyle,
                child: const Text('플래시카드 모드'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  // 4지선다 모드로 이동하는 코드 추가
                },
                style: buttonStyle,
                child: const Text('4지선다 모드'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  // 학습 모드로 이동하는 코드 추가
                },
                style: buttonStyle,
                child: const Text('학습 모드'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
