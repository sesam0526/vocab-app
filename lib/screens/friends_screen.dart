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

  var check=0;
  //List<String> list=[];
  
  @override
  Widget build(BuildContext context) {
    Future<QuerySnapshot<Object?>?> query=checkFr(); 
    // ignore: unnecessary_null_comparison
    if(query!=null){
      check=1;
    }
    
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
                    _addFriendScreen();
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
                    _rFriendList();
                  },
                  child: Row(
                    children: [
                      const Text('요청 리스트  '),
                      (check == 0)
                          ? const Icon(Icons.list)
                          : const Icon(Icons.list),
                      const Icon(Icons.priority_high, color: Colors.red)
                    ],
                  )),
            ]),
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
          )
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
      print(friendList);
      return friendList;
    });
  }
  

  
  
   Stream<List<String>> _getList(){
    User? user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return FirebaseFirestore.instance
        .collection('friends')
        .where('user_id', isEqualTo: user.email.toString())
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((QuerySnapshot query) {
      List<String> list = [];
      for (var doc in query.docs) {
        list.add(doc['friend_id']);
      }
      return list;
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

  Future<void> _addFriendScreen() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '친구 추가창',
            style: TextStyle(fontSize: 20),
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
      if(query.docs.isNotEmpty){
         check=1;
         /*
          for (var doc in query.docs) {
           list.add(doc['user_id']);
      }
      */
         return query;
      }else{
         check=0;
         return null;
      }
    }
    return null;
  }
/*
   void _requsetFriendCk() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('friends')
          .where('friend_id', isEqualTo: currentUser.uid)
          .get();

      if (query.docs.isNotEmpty) {
      } else {
        const Text('받은 요청이 존재하지 않습니다.');
      }
    }
  }
*/
  Future<void> _rFriendList() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null){
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('friends')
          .where('friend_id', isEqualTo: currentUser.email.toString())
          .get();
       
      // ignore: use_build_context_synchronously
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
        builder: (BuildContext context) {
          if (query.docs.isNotEmpty) {
            return const AlertDialog(
              title: Text(
                '친구 요청 리스트',
                style: TextStyle(fontSize: 20),
              ),
              //content:
              
            );
          } else {
            return const AlertDialog(
              title: Text(
                '친구 요청 리스트',
                style: TextStyle(fontSize: 20),
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
}
