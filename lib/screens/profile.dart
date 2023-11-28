/*import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  XFile? _pickedFile;

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
          const SizedBox(
            height: 20,
          ),
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
                      Icon(
                        Icons.account_circle,
                        size: imageSize,
                      ),
                      const SizedBox(height: 20),
                      nameTextField(),
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
                    fit: BoxFit.cover),
              ),
            ),
        ],
      ),
    );
  }

  Widget nameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
              width: 2,
            ),
          ),
          prefixIcon: Icon(
            Icons.person,
            color: Colors.black,
          ),
          labelText: '이름',
          hintText: '이름을 입력하시오'),
    );
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
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          const SizedBox(
            height: 20,
          ),
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
                      Icon(
                        Icons.account_circle,
                        size: imageSize,
                      ),
                      const SizedBox(height: 20),
                      nameTextField(),
                      const SizedBox(height: 20),
                      // 수정: 사용자 정보 출력
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getUserInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // 사용자 정보 출력
                            return Column(
                              children: [
                                Text(
                                  'score: ${snapshot.data!['score']}, '
                                  'money: ${snapshot.data!['money']}, '
                                  '순위: ${snapshot.data!['rank']}등',
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
                    fit: BoxFit.cover),
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

    // Firestore에서 해당 사용자의 데이터 가져오기
    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(currentUserEmail).get();

    // 사용자 정보를 Map으로 반환
    return {
      'score': userSnapshot['score'],
      'money': userSnapshot['money'],
      'rank': userSnapshot['rank'],
      // 여기에 추가적인 필드가 있다면 추가하세요.
    };
  }

  Widget nameTextField() {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
              width: 2,
            ),
          ),
          prefixIcon: Icon(
            Icons.person,
            color: Colors.black,
          ),
          labelText: '이름',
          hintText: '이름을 입력하시오'),
    );
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
