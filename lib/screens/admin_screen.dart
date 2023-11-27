import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'adminModfiy_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 관리'),
        backgroundColor: Colors.purple[400],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                '사용자 목록',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: usersCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('오류가 발생했습니다.');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  // 데이터가 있는 경우 사용자 목록 출력
                  final users = snapshot.data!.docs;
                  return Column(
                    children: users.map<Widget>((user) {
                      final userData = user.data() as Map<String, dynamic>;

                      // 필드들 가져오기
                      final id = userData['id'] ?? '없음';
                      final lives = userData['lives'] ?? '없음';
                      final money = userData['money'] ?? '없음';
                      final nickname = userData['nickname'] ?? '없음';
                      final pass = userData['pass'] ?? '없음';
                      final score = userData['score'] ?? '없음';

                      return Container(
                        margin: const EdgeInsets.all(10.0), // 각 사용자 사이의 간격 조절
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(15.0), // 네모의 모서리를 둥글게
                          border: Border.all(color: Colors.grey), // 테두리 색상 설정
                          color: const Color.fromARGB(255, 235, 235, 235),
                        ),
                        child: ListTile(
                          title: Text('ID: $id'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('이름: $nickname'),
                              Text('이메일: ${user.id}'),
                              Text('게임 점수: $score'),
                              Text('보유 포인트: $money'),
                              Text('보유 목숨 개수: $lives'),
                              Text('보유 패스 개수: $pass'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // 수정 기능 추가
                                  _showEditDialog(user.id, userData);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  // 삭제 기능 추가
                                  _showDeleteDialog(user.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 사용자 정보 수정 다이얼로그
  Future<void> _showEditDialog(
      String userId, Map<String, dynamic> userData) async {
    // Navigate to AdminModifyScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdminModifyScreen(userId: userId, userData: userData),
      ),
    );
  }

  // 사용자 삭제 다이얼로그
  Future<void> _showDeleteDialog(String userId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('사용자 삭제'),
          content: Text('($userId) 사용자를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 취소 버튼
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                // TODO: 사용자 삭제 로직을 여기에 추가하세요.
                await _deleteUser(userId);
                Navigator.of(context).pop(); // 확인 버튼
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  // 사용자 삭제 메서드
  Future<void> _deleteUser(String userId) async {
    try {
      // userId를 사용하여 해당 문서를 삭제
      await usersCollection.doc(userId).delete();

      // 사용자 삭제 성공 시 팝업 창 표시
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('사용자 삭제'),
            content: Text('($userId) 사용자가 삭제되었습니다.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 닫기 버튼
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // 오류 발생 시 팝업 창 표시
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('오류'),
            content: Text('사용자 삭제 중 오류가 발생했습니다: $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 닫기 버튼
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
}
