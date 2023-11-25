import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friend_information.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({Key? key}) : super(key: key);

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  List<String> list = [];

  @override
  Widget build(BuildContext context) {
    list = [];
    Future<QuerySnapshot<Object?>?> query = checkFr();
    var myFuture = _getFriendList();
    // ignore: unnecessary_null_comparison
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 목록'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _addFriendScreen();
                    });
                  },
                  style: const ButtonStyle(
                      // padding: MaterialStateProperty.all(const EdgeInsets.all(20.0)),

                      ),
                  child: const Row(
                    children: [
                      Text('친구 추가  '),
                      Icon(Icons.person_add_alt),
                    ],
                  )),
              const SizedBox(width: 20),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _rFriendList();
                    });
                  },
                  child: Row(
                    children: [
                      const Text('요청 리스트  '),
                      (list.isEmpty)
                          ? const Icon(Icons.list)
                          : const Icon(Icons.priority_high, color: Colors.red)
                    ],
                  )),
            ]),
          ),
          Expanded(
              child: FutureBuilder<QuerySnapshot>(
                  future: myFuture,
                  builder: (context, snapshot) {
                    final documents = snapshot.data?.docs ?? [];
                    if (documents.isEmpty) {
                      return const Center(child: Text("친구가 없습니다."));
                    }
                    return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            onTap: () {
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FriendInfo(),
                                  ),
                                );
                              });
                            },
                            leading: Text(
                              documents[index].get('friend_name'),
                              style: const TextStyle(fontSize: 20),
                            ),
                            trailing: Text(
                              documents[index].get('friend_id'),
                              style: const TextStyle(fontSize: 15),
                            ),
                          );
                        });
                  })),
        ],
      ),
    );
  }

  Future<QuerySnapshot> _getFriendList() async {
    User? user = _auth.currentUser;
    return FirebaseFirestore.instance
        .collection('friends')
        .where('user_id', isEqualTo: user!.email.toString())
        .where('status', isEqualTo: 'accepted')
        .get();
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
        /*
        await FirebaseFirestore.instance.collection('friends').add({
          'user_id': currentUser.email,
          'friend_id': friendUid,
          'status': 'pending',
        });
        */
        await FirebaseFirestore.instance
            .collection('friends')
            .doc(currentUser.email! + friendUid)
            .set({
          'user_id': currentUser.email,
          'friend_id': friendUid,
          'status': 'pending',
          'user_name': currentUser.displayName,
          'friend_name': 'null'
        });
        await FirebaseFirestore.instance
            .collection('friends')
            .doc(friendUid + currentUser.email!)
            .set({
          'user_id': friendUid,
          'friend_id': currentUser.email,
          'status': 'pending',
          'friend_name': currentUser.displayName,
          'user_name': 'null'
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('친구요청을 보냈습니다.'),
          ),
        );
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

  Future<void> _addFriendScreen() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '친구 추가창',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              //List Body를 기준으로 Text 설정
              children: <Widget>[
                Text('요청보낼 친구의 이메일을 입력하세요.'),
              ],
            ),
          ),
          actions: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '친구의 이메일',
              ),
            ),
            Row(
              children: [
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      _sendFriendRequest(_emailController.text);
                      _emailController.clear();
                      Navigator.of(context).pop();
                    },
                    child: const Row(
                      children: [Text('요청 보내기  '), Icon(Icons.person_add_alt)],
                    )),
              ],
            )
          ],
        );
      },
    );
  }

  Future<QuerySnapshot<Object?>?> checkFr() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('friends')
          .where('friend_id', isEqualTo: currentUser.email.toString())
          .where('status', isEqualTo: 'pending')
          .get();
      if (query.docs.isNotEmpty) {
        for (var doc in query.docs) {
          list.add(doc['user_id']);
        }
        return query;
      } else {
        return null;
      }
    }
    return null;
  }

  Future<void> _rFriendList() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // ignore: use_build_context_synchronously
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
        builder: (BuildContext context) {
          if (list.isNotEmpty) {
            return AlertDialog(
              title: const Text(
                '친구 요청 리스트',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    for (int i = 0; i < list.length; i++)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(list[i], style: const TextStyle(fontSize: 18)),
                            Container(
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          //삭제
                                          _CancleFriend(list[i]);
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      icon: const Icon(Icons.cancel)),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          //친구추가
                                          _AddFriend(list[i]);
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      icon: const Icon(Icons.check_circle))
                                ],
                              ),
                            ),
                          ])
                  ],
                ),
              ),
              elevation: 10,
            );
          } else {
            return const AlertDialog(
              title: Text(
                '친구 요청 리스트',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Text('받은 요청이 존재하지 않습니다.'),
              ),
            );
          }
        },
      );
    }
  }

  Future<void> _CancleFriend(String st) async {
    FirebaseFirestore.instance
        .collection('friends')
        .doc(st + _auth.currentUser!.email.toString())
        .delete();
    FirebaseFirestore.instance
        .collection('friends')
        .doc(_auth.currentUser!.email.toString() + st)
        .delete();
  }

  Future<void> _AddFriend(String st) async {
    User? user = _auth.currentUser;
    FirebaseFirestore.instance
        .collection('friends')
        .doc(st + user!.email.toString())
        .update({'status': 'accepted', 'friend_name': user.displayName});
    FirebaseFirestore.instance
        .collection('friends')
        .doc(user.email.toString() + st)
        .update({'status': 'accepted', 'user_name': user.displayName});
  }
}
