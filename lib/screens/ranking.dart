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
        backgroundColor: Colors.purple[400],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .orderBy('score', descending: true)
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

              // 현재 사용자의 'id'와 'score'
              String? currentUserID = _auth.currentUser?.uid;
              int? currentUserScore;

              // 이전 데이터의 score 값
              int? prevScore;
              // 이전 데이터의 순위
              int? prevRank;

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: documents.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic>? data =
                      documents[index].data() as Map<String, dynamic>?;

                  // 'money', 'score', 'id' 필드가 있는지 확인
                  if (data?.containsKey('money') == true &&
                      data?.containsKey('score') == true &&
                      data?.containsKey('id') == true) {
                    // 현재 데이터의 score 값
                    int currentScore = data!['score'];
                    // 현재 사용자의 'score'값 설정
                    if (data['id'] == currentUserID) {
                      currentUserScore = currentScore;
                    }
                    // 현재 데이터의 score가 이전 데이터의 score와 같다면 같은 순위로 처리
                    int currentRank =
                        (prevScore == currentScore) ? prevRank! : index + 1;

                    // 이전 데이터의 값을 현재로 업데이트
                    prevScore = currentScore;
                    prevRank = currentRank;

                    // 중복된 순위를 제거
                    if (index > 0 &&
                        documents[index - 1]['score'] ==
                            documents[index]['score']) {
                      return Container(); // 중복된 순위의 경우 빈 Container 반환
                    }

                    // 순위를 나타내는 문자열 구성
                    String rank = '$currentRank위';

                    // 현재 순위의 사용자 목록
                    List<String> currentRankUsers = [];

                    // 현재 순위의 사용자들을 currentRankUsers 리스트에 추가
                    for (int i = index; i < documents.length; i++) {
                      final userData =
                          documents[i].data() as Map<String, dynamic>;
                      if (userData['score'] == currentScore) {
                        currentRankUsers.add(userData['id']);
                      } else {
                        break;
                      }
                    }

                    // currentRankUsers 리스트를 'id' 기준으로 정렬
                    currentRankUsers.sort();

                    // 사용자 정보와 선을 출력
                    return Column(
                      children: [
                        ...currentRankUsers.map((id) {
                          // rank를 firebase에 저장
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(
                                  id) // Assuming 'id' is the document ID of the user
                              .update({'rank': currentRank});

                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.purple!),
                                  ),
                                ),
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$rank',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        'ID: $id',
                                        style: _auth.currentUser?.email == id
                                            ? const TextStyle(
                                                fontSize: 20,
                                                color: Colors
                                                    .red) // 로그인한 사용자의 ID인 경우
                                            : const TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        'Score: ${data['score']}',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    );
                  } else {
                    return const ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      title: Text(
                        'Money가 존재하지 않습니다.',
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
