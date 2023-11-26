import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Ranking extends StatefulWidget {
  const Ranking({Key? key}) : super(key: key);

  @override
  _RankingState createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('랭킹'),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .orderBy('score', descending: false)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('에러 발생: ${snapshot.error}'),
            );
          }

          final documents = snapshot.data?.docs ?? [];
          if (documents.isEmpty) {
            return const Center(child: Text("데이터가 없습니다."));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic>? data =
                  documents[index].data() as Map<String, dynamic>?;

              // 'money' 필드가 있는지 확인
              if (data?.containsKey('money') == true &&
                  data?.containsKey('score') == true) {
                // 순위를 나타내는 문자열 구성
                String rank = (index + 1).toString() + '위';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text(
                    '$rank ID: ${data!['id']}, Score: ${data['score']}',
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              } else {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: const Text(
                    'Money가 존재하지 않습니다.',
                    style: TextStyle(fontSize: 15),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
