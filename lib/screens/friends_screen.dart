import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({Key? key}) : super(key: key);

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 목록'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '친구의 이메일',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _sendFriendRequest(_emailController.text);
                    _emailController.clear();
                  },
                  child: const Row(children: [
                    Text('친구 요청 보내기  '),
                    Icon(Icons.person_add_alt),
                  ],)
                  
                  
                ),
              ],
            ),
          ),
          StreamBuilder<List<String>>(
            stream: _getFriendList(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              List<String> friends = snapshot.data ?? [];
              return Expanded(
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(friends[index]),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Stream<List<String>> _getFriendList() {
    User? user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('friends')
        .where('user_id', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((QuerySnapshot query) {
      List<String> friendList = [];
      for (var doc in query.docs) {
        friendList.add(doc['friend_id']);
      }
      return friendList;
    });
  }

  
  void _sendFriendRequest(String friendEmail) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // 이메일을 사용하여 사용자 UID 가져오기
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: friendEmail)
          .get();

      if (query.docs.isNotEmpty) {
        String friendUid = query.docs.first.id;

        // Firestore "friends" 콜렉션에 친구 요청 추가
        await FirebaseFirestore.instance.collection('friends').add({
          'user_id': currentUser.email,
          'friend_id': friendUid,
          'status': 'pending',
        });
      } else {
        // 사용자를 찾을 수 없음을 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('입력한 이메일을 가진 사용자를 찾을 수 없습니다.'),
          ),
        );
      }
    }
  }
}
