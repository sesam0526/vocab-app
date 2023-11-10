import 'package:flutter/material.dart';

class WordList extends StatefulWidget {
  const WordList({Key? key}) : super(key: key);

  @override
  _WordListState createState() => _WordListState();
}

class _WordListState extends State<WordList> {
  List<Map<String, String>> yourWordList = [];

  void addWord(String word, String meaning) {
    setState(() {
      yourWordList.add({'word': word, 'meaning': meaning});
    });
  }

  TextEditingController _wordController = TextEditingController();
  TextEditingController _meaningController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('단어장'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '나의 단어장',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              // 단어와 뜻을 추가하는 TextField
              TextField(
                controller: _wordController,
                decoration: InputDecoration(labelText: '단어'),
              ),
              TextField(
                controller: _meaningController,
                decoration: InputDecoration(labelText: '뜻'),
              ),
              ElevatedButton(
                onPressed: () {
                  // 버튼을 누르면 단어와 뜻 추가
                  addWord(_wordController.text, _meaningController.text);
                  // 입력된 단어와 뜻을 목록에 추가하고 텍스트 필드 초기화
                  _wordController.clear();
                  _meaningController.clear();
                },
                child: Text('단어 추가'),
              ),
              // 단어 목록을 나타내는 ListView
              ListView.builder(
                shrinkWrap: true,
                itemCount: yourWordList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('단어: ${yourWordList[index]['word'] ?? ''}'),
                    subtitle: Text('뜻: ${yourWordList[index]['meaning'] ?? ''}'),
                    // 다른 기능 추가 가능
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WordList(),
  ));
}
