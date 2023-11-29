import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      ),
      body: Column(
        children: [
          //사진을 선택하지 않았을때
          if (_pickedFile == null)
            Container(
              constraints: BoxConstraints(
                minHeight: imageSize,
                minWidth: imageSize,
              ),
              child: GestureDetector(
                onTap: () {
                  _showBottomeSheet();
                },
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: imageSize,
                        height: imageSize,
                        margin: EdgeInsets.only(top: 40), // 이미지를 아래로 20 포인트 이동
                        decoration: BoxDecoration(
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
                                Text(
                                  'id ',
                                  style: TextStyle(
                                    color: Colors.grey, // 회색
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  '${snapshot.data!['id'] ?? 'DefaultNickid'}\n',
                                  style: TextStyle(
                                    color: Colors.black, // 검정
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'nickname ',
                                  style: TextStyle(
                                    color: Colors.grey, // 회색
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  '${snapshot.data!['nickname'] ?? 'DefaultNickname'}\n',
                                  style: TextStyle(
                                    color: Colors.black, // 검정
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'score ',
                                  style: TextStyle(
                                    color: Colors.grey, // 회색
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  '${snapshot.data!['score']}\n',
                                  style: TextStyle(
                                    color: Colors.black, // 검정
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'rank ',
                                  style: TextStyle(
                                    color: Colors.grey, // 회색
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  '${snapshot.data!['rank']}위\n',
                                  style: TextStyle(
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
    );
  }

  // 수정: 사용자 정보 가져오기
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

  _showBottomeSheet() {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => _getCameraimage(),
              child: const Text('촬영'),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              thickness: 3,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () => _getPhotoLibraryImage(),
              child: const Text('갤러리에서 불러오기'),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }

  _getCameraimage() async {
    //촬영
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택 안 함');
      }
    }
  }

  _getPhotoLibraryImage() async {
    //갤러리에서 사진 불러오기
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    } else {
      if (kDebugMode) {
        print('이미지 선택 안 함');
      }
    }
  }
}
