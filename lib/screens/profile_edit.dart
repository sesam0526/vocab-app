import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class profile_edit extends StatefulWidget {
  const profile_edit({Key? key}) : super(key: key);
  @override
  _profile_editState createState() => _profile_editState();
}

class _profile_editState extends State<profile_edit> {
  //late TextEditingController _nicknameController;
  TextEditingController _nicknameController = TextEditingController();
  String userId = FirebaseAuth.instance.currentUser!.email.toString();

  @override
  void initState() {
    super.initState();
  }

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
              // User ID를 나타낸다.
              Text(
                'ID: ${userId}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              // 닉네임 수정
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: 'nickname'),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    //  Firestore에 사용자 정보를 업데이트하는 메서드 호출
                    await _updateUserInfo();
                    // 이전 화면인 profile로 돌아간다.
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.done), // 아이콘 설정
                  label: Text(''), // 빈 텍스트 설정 또는 label을 제거
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
      // 닉네임 컨트롤러의 값을 가져옴
      String newNickname = _nicknameController.text;

      // 닉네임이 비어 있으면 Firestore에서 이전 닉네임을 가져옴
      if (newNickname.isEmpty) {
        // 이전 닉네임 가져오기
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        // 이전 닉네임이 있는지 확인 후 설정
        if (userDoc.exists) {
          newNickname = userDoc['nickname'];
        } else {
          // 이전 닉네임이 없으면 기본값 설정 (원하는 값으로 변경)
          newNickname = '';
        }
      }

      // Firestore에서 사용자 정보 업데이트
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'nickname': newNickname});

      // 성공 메시지 표시 또는 성공에 따라 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임이 성공적으로 수정되었습니다.')),
      );
    } catch (e) {
      // 오류 처리 및 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임 수정 중 오류가 발생하였습니다: $e')),
      );
    }
  }
}
