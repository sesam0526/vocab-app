import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendInfo extends StatefulWidget {
  String email = '';
  FriendInfo({super.key, required this.email});

  @override
  _FriendInfo createState() => _FriendInfo(email: email);
}

class _FriendInfo extends State<FriendInfo> {
  String email = '';
  _FriendInfo({required this.email});

  String nickname = '';
  int score = 0;

  @override
  Widget build(BuildContext context) {
    _getUserInpomation(email);
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 정보'),
        backgroundColor: Colors.purple[400],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1))),
                  width: double.infinity,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const Text('이름',style: TextStyle(fontSize: 25)),Text(nickname,style: const TextStyle(fontSize: 25),)],
                  ),),
              Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: const BoxDecoration(
                    border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1))),
                  width: double.infinity,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const Text('이메일',style: TextStyle(fontSize: 25)),Text(email,style: const TextStyle(fontSize: 25),)],
                  ),),
              Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: const BoxDecoration(
                     border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1))),
                  width: double.infinity,
                  height: 80,
                   child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const Text('게임 점수',style: TextStyle(fontSize: 25)),Text(score.toString(),style: const TextStyle(fontSize: 25),)],
                  ),),
              ElevatedButton(
                onPressed: (){

                }, 
                 child: const Text('단어장',style: TextStyle(fontSize: 20),))
               
            ],
          ),
        ),
      ),
    );
  }

  //합수 구현
  Future<void> _getUserInpomation(String em) async {
    DocumentSnapshot<Map<String, dynamic>> query =
        await FirebaseFirestore.instance.collection('users').doc(em).get();

    if (mounted) {
      setState(() {
        nickname = query.data()!['nickname'];
        score = query.data()!['score'];
      });
    }
  }

  void _getVocabulary() async{
     return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '삭제 확인창',
            style: TextStyle(fontSize: 20),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              //List Body를 기준으로 Text 설정
              children: <Widget>[
                Text('정말 삭제하시겠습니까?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('삭제'),
              onPressed: () {
                
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
              
              },
            ),
          ],
        );
      },
    );
  }
}
