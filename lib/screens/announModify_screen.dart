import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnounModifyScreen extends StatefulWidget {
  final String announId;
  final String title;
  final String mainText;

  const AnnounModifyScreen({
    required this.announId,
    required this.title,
    required this.mainText,
    Key? key,
  }) : super(key: key);

  @override
  _AnnounModifyScreenState createState() => _AnnounModifyScreenState();
}

class _AnnounModifyScreenState extends State<AnnounModifyScreen> {
  late TextEditingController _titleController;
  late TextEditingController _mainTextController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _mainTextController = TextEditingController(text: widget.mainText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항 수정'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '제목',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '내용',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _mainTextController,
                maxLines: null, // Allows multiple lines
                decoration: const InputDecoration(
                  hintText: '내용을 입력하세요',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, // Make the button take the full width
                child: ElevatedButton(
                  onPressed: () {
                    // Update Firestore document
                    updateAnnouncement();
                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateAnnouncement() async {
    try {
      await FirebaseFirestore.instance
          .collection('Announcement')
          .doc(widget.announId)
          .update({
        'title': _titleController.text,
        'main text': _mainTextController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공지사항이 수정되었습니다.'),
        ),
      );
    } catch (error) {
      print('Error updating announcement: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('수정 중 오류가 발생했습니다.'),
        ),
      );
    }
  }
}
