import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'profile_edit.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  XFile? _pickedFile;

  // Firebase 인증 및 Firestore 인스턴스 생성
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width / 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        backgroundColor: Colors.purple[400],
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //사진을 선택하지 않았을때
            if (_pickedFile == null)
              Container(
                constraints: BoxConstraints(
                  minHeight: imageSize,
                  minWidth: imageSize,
                ),
                child: GestureDetector(
                  //onTap: () {
                  //  _showBottomeSheet();
                  //},
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: imageSize,
                          height: imageSize,
                          margin: const EdgeInsets.only(
                              top: 40), // 이미지를 아래로 40 포인트 이동
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/mufin1.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 수정: 사용자 정보 출력
                        FutureBuilder<Map<String, dynamic>>(
                          future: _getUserInfo(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              // 사용자 정보 출력
                              return Column(
                                children: [
                                  const Text(
                                    'id ',
                                    style: TextStyle(
                                      color: Colors.grey, // 회색
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    '${snapshot.data!['id'] ?? 'DefaultNickid'}\n',
                                    style: const TextStyle(
                                      color: Colors.black, // 검정
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Text(
                                    'nickname ',
                                    style: TextStyle(
                                      color: Colors.grey, // 회색
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    '${snapshot.data!['nickname'] ?? 'DefaultNickname'}\n',
                                    style: const TextStyle(
                                      color: Colors.black, // 검정
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Text(
                                    'score ',
                                    style: TextStyle(
                                      color: Colors.grey, // 회색
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    '${snapshot.data!['score']}\n',
                                    style: const TextStyle(
                                      color: Colors.black, // 검정
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Text(
                                    'point ',
                                    style: TextStyle(
                                      color: Colors.grey, // 회색
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    '${snapshot.data!['money']}\n',
                                    style: const TextStyle(
                                      color: Colors.black, // 검정
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Text(
                                    'rank ',
                                    style: TextStyle(
                                      color: Colors.grey, // 회색
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    '${snapshot.data!['rank']}위\n',
                                    style: const TextStyle(
                                      color: Colors.black, // 검정
                                      fontSize: 20,
                                    ),
                                  ),

                                  // 여기에 추가적인 정보를 출력할 수 있습니다.
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 2, color: Theme.of(context).colorScheme.primary),
                  image: DecorationImage(
                    image: FileImage(File(_pickedFile!.path)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>> _getUserInfo() async {
    // 현재 사용자의 이메일 가져오기
    String? currentUserEmail = _auth.currentUser?.email;

    try {
      // Firestore에서 해당 사용자의 데이터 가져오기
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(currentUserEmail).get();

      // 사용자 정보를 Map으로 반환
      return {
        'id': userSnapshot['id'],
        'nickname': userSnapshot['nickname'],
        'score': userSnapshot['score'],
        'money': userSnapshot['money'],
        'rank': userSnapshot['rank'],
        // 여기에 추가적인 필드가 있다면 추가하세요.
      };
    } catch (e) {
      print('Eror getting user info: &e');
      return {
        'id': 'default',
        'nicknmae': 'default', // 에러 시 기본값 설정
        'score': 0,
        'money': 0,
        'rank': 0,
      };
    }
  }

  // 닉네임 수정 다이얼로그
  Future<void> _showEditDialog() async {
    // Navigate to AdminModifyScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const profile_edit(),
      ),
    );
  }
}
