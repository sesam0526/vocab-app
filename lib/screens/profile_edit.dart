import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class profile_edit extends StatefulWidget {
  const profile_edit({Key? key}) : super(key: key);
  @override
  _profile_editState createState() => _profile_editState();
}

class _profile_editState extends State<profile_edit> {
  final TextEditingController _nicknameController = TextEditingController();
  String userId = FirebaseAuth.instance.currentUser!.email.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('닉네임 수정'),
        backgroundColor: Colors.purple[400],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: $userId',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: 'nickname'),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (mounted) {
                      //  Firestore에 사용자 정보를 업데이트하는 메서드 호출
                      await _updateUserInfo();
                      // 이전 화면인 profile로 돌아간다.
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.done),
                  label: const Text(''),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateUserInfo() async {
    try {
      String newNickname = _nicknameController.text;

      if (newNickname.isEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          newNickname = userDoc['nickname'];
        } else {
          newNickname = '';
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'nickname': newNickname});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임이 성공적으로 수정되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임 수정 중 오류가 발생하였습니다: $e')),
      );
    }
  }
}
