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
  int req_ck = 0;

  @override
  Widget build(BuildContext context) {
    list = [];
    Future<QuerySnapshot<Object?>?> query = checkFr();
    var myFuture = _getFriendList();
    // ignore: unnecessary_null_comparison
    //친구 목록창 구현
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 목록'),
        backgroundColor: Colors.purple[400],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              //친구 추가
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      //친구 추가를 위한 팝업창을 불러오는 함수
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
              const SizedBox(width: 20), //띄우기
             //친구 요청 리스트
              ElevatedButton(
                  onPressed: () {
                     //받은 친구 요청리스트를 출력하는 팝업창을 불러오는 함수
                    setState(() {
                      _rFriendList();
                    });
                  },
                  child: const Row(
                    children: [
                      Text('요청 리스트  '),
                      Icon(Icons.list),
                    ],
                  )),
            ]),
          ),
          //친구리스트 출력
          Expanded(
              child: FutureBuilder<QuerySnapshot>(
                  future: myFuture, //친구 리스트를 데이터베이터에서 받아옴
                  builder: (context, snapshot) {
                    final documents = snapshot.data?.docs ?? [];
                    if (documents.isEmpty) {//받아온 데이터가 비어있을 때-> 친구가 없다.
                      return const Center(child: Text("친구가 없습니다."));
                    }
                    return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          String email = documents[index].get('friend_id');
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            onTap: () async {
                              //친구를 클릭했을 떄 친구 정보를 볼 수 있는 창으로 이동
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FriendInfo(email: email),
                                ),
                              );
                            },
                            leading: Text( //친구 닉네임 출력
                              documents[index].get('friend_name'),
                              style: const TextStyle(fontSize: 20),
                            ),
                            trailing: Text( //친구 이메일 출력
                              email,
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
    //친구 리스트를 데이터베이스에서 받아오는 함수
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
      // 입력받은 이메일을 사용하여 그 이메일 유저의 정보 받기
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: friendEmail)
          .get();
      DocumentSnapshot<Map<String, dynamic>> query2 = await FirebaseFirestore
          .instance
          .collection('friends')
          .doc(currentUser.email.toString() + friendEmail)
          .get();
      if (friendEmail == currentUser.email) {
        //입력한 이메일이 자기 자신의 이메일인 경우, 본인에게 친구신청은 안됨을 출력
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('자기 자신에게 친구신청은 보낼 수 없습니다.'),
          ),
        );
      } else if (query.docs.isNotEmpty &&
          !query2.exists &&
          friendEmail != currentUser.email) {
            //입력받은 이메일 유저가 존재하고, 아직 사용자의 친구정보와 관련없고, 자기자신의 이메일이 아닌 경우 친구신청을 보냄
        String friendUid = query.docs.first.id;
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
        //성공적으로 보냄을 사용자에 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('친구요청을 보냈습니다.'),
          ),
        );
      } else if (query2.exists && query2.data()!['status'] == 'accepted') {
        //이미 친구인 경우
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 친구입니다.'),
          ),
        );
      } else if (query2.exists && query2.data()!['status'] == 'pending') {
        //친구 정보에서 아직 상태가 pending인 경우
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 친구 신청을 받거나 보낸 상태입니다.'),
          ),
        );
      } else if (query.docs.isEmpty) {
        // 사용자를 찾을 수 없음을 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('입력한 이메일을 가진 사용자를 찾을 수 없습니다.'),
          ),
        );
      } else {
        //그 외의 경우
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('알 수 없는 오류'),
          ),
        );
      }
    }
  }

  Future<void> _addFriendScreen() async {
    //친구 추가 팝업창
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
            //추가할 친구의 이메일 입력 텍스트필드
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '친구의 이메일',
              ),
            ),
            Row(
              children: [
                //취소 버튼-> 아무작업없이 창 나가기
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                ),
                //입력한 이메일 정보를 바탕으로 친구신청 시도(자세한 설명은 함수쪽 주석 참고)
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sendFriendRequest(_emailController.text);
                        _emailController.clear();
                        Navigator.of(context).pop();
              
                      });
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
    //사용자에게 친구신청을 보낸 게 있는지 확인, 있으면 list에 추가하는 함수
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      //데이터베이스에서 데이터 가져오기
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('friends')
          .where('friend_id', isEqualTo: currentUser.email.toString())
          .where('status', isEqualTo: 'pending')
          .where('friend_name', isEqualTo: 'null')
          .get();
      if (query.docs.isNotEmpty) {
        //query가 비어있지 않다면 그 값들을 list에 저장
        for (var doc in query.docs) {
          list.add(doc['user_id']);
        }
        req_ck = list.length;
        return query;
      } else {
        return null;
      }
    }
    return null;
  }

  Future<void> _rFriendList() async {
    //받은 친구요청리스트를 팝업창으로 띄우는 함수
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
                    //list의 길이만큼 돌면서 row로 리스트를 표시
                    for (int i = 0; i < list.length; i++)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //보낸 이의 이메일 표시
                            Flexible(child: Text(list[i], style: const TextStyle(fontSize: 18)),),
                            Container(
                              
                              child: Row(
                                children: [
                                  IconButton(
                                    //x 아이콘-> 누르면 친구요청을 거절함, DB에서 정보 삭제 후 팝업 닫기
                                      onPressed: () {
                                        //삭제
                                        _CancleFriend(list[i]);
                                        req_ck = list.length;
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.cancel)),
                                  IconButton(
                                    // o 아이콘-> 누르면 친구요청 수락함, DB에 저장 후 팝업 닫기
                                      onPressed: () {
                                        setState(() {
                                          //친구추가
                                          _AddFriend(list[i]);
                                          _getFriendList();
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
            //받은 친구요청이 존재하지 않을 때 없음을 출력함
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
    //친구요청을 거절하면 호출되는 함수로 DB에서 삭제하는 기능
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
    //친구요청을 수락하면 호출되는 함수로 DB의 정보를 수정하는 기능
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
