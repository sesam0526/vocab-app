import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'friend_vocab.dart';

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
                  children: [
                    const Text('이름', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
                    Text(
                      nickname,
                      style: const TextStyle(fontSize: 25),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.black, width: 1))),
                width: double.infinity,
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('이메일', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 25),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.black, width: 1))),
                width: double.infinity,
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('게임 점수', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
                    Text(
                      score.toString(),
                      style: const TextStyle(fontSize: 25),
                    )
                  ],
                ),
              ),
              ElevatedButton(
                
                  onPressed: () async{
                     final result=await
                     Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FriendVocab(email:email)));
                   
                  },
                  child: const Text(
                    '단어장',
                    style: TextStyle(fontSize: 20),
                  ))
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
  
}


