import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddAnnounScreen extends StatefulWidget {
  // 공지사항 추가 창
  const AddAnnounScreen({Key? key}) : super(key: key);

  @override
  _AddAnnounScreen createState() => _AddAnnounScreen();
}

class _AddAnnounScreen extends State<AddAnnounScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  String mainText = '';

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항 추가'),
        backgroundColor: Colors.purple[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '공지사항 타이틀',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14.0),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: TextField(
                      maxLines: null,
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: '공지사항 내용',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 공지사항 저장하고 창 나가기
          if (_textController.text.isNotEmpty &&
              _titleController.text.isNotEmpty) {
            uploadAnnoun(_titleController.text, _textController.text);
            _titleController.clear();
            _textController.clear();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('공지사항을 업로드하였습니다.'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('빈 칸으로 업로드할 수 없습니다.'),
              ),
            );
          }
        },
        label: const Text(
          '업로드',
          style: TextStyle(fontSize: 20),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> uploadAnnoun(String name, String text) async {
    // 현재 날짜와 시간에 대한 타임스탬프 생성
    DateTime now = DateTime.now();
    Timestamp timestamp = Timestamp.fromDate(now);
    // 텍스트필드에 적은 내용을 DB에 저장
    await FirebaseFirestore.instance
        .collection('Announcement')
        .doc(now.toString())
        .set({
      'title': name,
      'main text': text,
      'timestamp': timestamp,
    });
  }
}
