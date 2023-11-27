import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Announcement.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'VocabularyScreen.dart';
import 'admin_screen.dart';
import 'game_screen.dart';
import 'profile.dart';
import 'friends_screen.dart';
import 'ranking.dart';
import 'signin_screen.dart';
import 'store_screen.dart';
import 'wrongVocabulary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final _textController = TextEditingController();

  DateTime selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final DateTime _today = DateTime.now();
  Map<String, dynamic> dayMap = {};
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    String uid = 'nul';
    String uname = 'null';

    if (auth.currentUser != null) {
      uid = auth.currentUser!.email.toString();
      uname = auth.currentUser!.displayName.toString();
      CollectionReference<Map<String, dynamic>> attemL = FirebaseFirestore
          .instance
          .collection("users")
          .doc(uid)
          .collection("Attendance");
      _makeMap(attemL);
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        //앱바 구성
        title: const Text('영단어 사전'),
        centerTitle: true, //타이틀 중앙 위치
        elevation: 0.0, //입체감 없애기
        backgroundColor: Colors.purple[400],
        actions: [
          IconButton(
            //프로필 버튼 누르면 프로필 창으로 이동
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Profile()));
            },
            icon: const Icon(Icons.person),
          )
        ],
      ),
      drawer: Drawer(
          child: ListView(
        children: [
          UserAccountsDrawerHeader(
            //유저 헤더
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
            ),
            accountName: Text(uname),
            accountEmail: Text(uid),
            onDetailsPressed: () {}, // 디테일
            decoration: BoxDecoration(
                color: Colors.purple[200],
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
          ),
          ListTile(
            //단어장으로 이동
            leading: const Icon(Icons.view_list),
            title: const Text('단어장'),
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VocabularyScreen()));
            },
          ),
          ListTile(
            // 오답노트로 이동
            leading: const Icon(Icons.book),
            title: const Text('오답노트'),
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WrongVocabularyScreen()));
            },
          ),
          ListTile(
            // 게임으로 이동
            leading: const Icon(Icons.sports_esports),
            title: const Text('게임'),
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const GameScreen()));
            },
          ),
          ListTile(
            //유저들의 랭킹창으로 이동
            leading: const Icon(Icons.format_list_numbered),
            title: const Text('랭킹'),
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Ranking()));
            },
          ),
          ListTile(
            //상점으로 이동
            leading: const Icon(Icons.shopping_cart),
            title: const Text('상점'),
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const StoreScreen()));
            },
          ),
          ListTile(
            //친구 목록으로 이동
            leading: const Icon(Icons.person),
            title: const Text('친구 목록'),
            iconColor: Colors.purple,
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FriendScreen()));
            },
          ),
          ListTile(
            //공지사항으로 이동
            leading: const Icon(Icons.announcement),
            title: const Text('공지사항'),
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AnnouncementScreen()));
            },
          ),
          Visibility(
            //master@gmail.com일 경우에만 해당 메뉴 보임
            visible:
                FirebaseAuth.instance.currentUser?.email == 'master@gmail.com',
            child: ListTile(
              leading: const Icon(Icons.supervisor_account),
              title: const Text('사용자 관리'),
              iconColor: Colors.purple,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
              },
            ),
          ),
          ListTile(
              //로그아웃
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃'),
              iconColor: Colors.purple,
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()));
                });
              }),
        ],
      )),
      body: Center(
          child: Column(children: [
        //달력 구현
        TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2021, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          //날짜 클릭 시 클릭한 날짜로 selectedDay 설정
          onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
            setState(() {
              this.selectedDay = selectedDay;
              // this.focusedDay = focusedDay;
            });
          },
          selectedDayPredicate: (DateTime day) {
            return isSameDay(selectedDay, day);
          },
          onPageChanged: (focusedDay) {
            // No need to call `setState()` here
            _focusedDay = focusedDay;
          },
          //달력 디자인 설정
          headerStyle: const HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: TextStyle(
              fontSize: 20.0,
            ),
            leftChevronIcon: Icon(
              Icons.arrow_left,
              size: 40.0,
            ),
            rightChevronIcon: Icon(
              Icons.arrow_right,
              size: 40.0,
            ),
          ),
          calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              selectedDecoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.deepPurple, width: 1.0),
              ),
              selectedTextStyle: const TextStyle(
                fontSize: 16.0,
              ),
              todayDecoration: BoxDecoration(
                  //color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple, width: 1.5)),
              todayTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              markerSize: 10,
              markerDecoration: const BoxDecoration(
                color: Color.fromARGB(255, 144, 40, 162),
                shape: BoxShape.circle,
              )),
          //출석된 날짜들을 이벤트로 표시
          eventLoader: (day) {
            if (dayMap.containsKey(
                DateFormat('yyyy-MM-dd', 'ko').format(day).toString())) {
              return ["출석"];
            } else {
              return [];
            }
          },
        ),
        Padding(
          //선택한 날짜 표시
          padding: const EdgeInsets.all(0.0),
          child: Column(children: [
            Container(
                color: Colors.purple[50],
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy.MM.dd', 'ko')
                          .format(selectedDay)
                          .toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 2.0),
                    ),
                  ],
                )),
          ]),
        ),
        Padding(
          //to-do 입력할 텍스트박스
          padding: const EdgeInsets.all(8.0),

          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  controller: _textController,
                ),
              ),
              //추가 버튼
              ElevatedButton(
                onPressed: () {
                  if (_textController.text == '') {
                    return;
                  } else {
                    setState(() {
                      _taskAdder(uid, _textController.text, selectedDay);
                      _textController.clear();
                    });
                  }
                },
                child: const Text("추가"),
              )
            ],
          ),
        ),
        //해당 날짜의 to-do list
        Expanded(
          child: FutureBuilder<QuerySnapshot>(
              future: readList(uid, selectedDay),
              builder: (context, snapshot) {
                final documents = snapshot.data?.docs ?? [];
                if (documents.isEmpty) {
                  return const Center(child: Text("할 일이 없습니다."));
                }
                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    String work = doc.get('work');
                    bool isComplete = doc.get('isComplete');
                    String id = doc.id;
                    return ListTile(
                        onTap: () {
                          setState(() {
                            _taskUpdate(uid, id, isComplete);
                          });
                        },
                        trailing: IconButton(
                          icon: const Icon(CupertinoIcons.delete),
                          onPressed: () {
                            _taskDelete(uid, id);
                          },
                        ),
                        title: Text(
                          work,
                          style: isComplete
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontStyle: FontStyle.italic,
                                )
                              : null,
                        ));
                  },
                );
              }),
        ),
      ])),
      //출석 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //출석하기 함수 호출
          setState(() {
            attenCheck(uid);
          });
        },
        child: const Text(
          '출석',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  void _taskAdder(String uid, String work, DateTime date) {
    //to-do를 데이터베이스에 추가하는 함수
    final taskAdd = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("To-do list")
        .doc();
    taskAdd.set({
      "work": work,
      "isComplete": false,
      "date": DateFormat('yyyy.MM.dd', 'ko').format(date).toString()
    });
  }

  Future<QuerySnapshot> readList(String uid, DateTime date) async {
    //to-do list를 가져오는 합수
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("To-do list")
        .where("date",
            isEqualTo: DateFormat('yyyy.MM.dd', 'ko').format(date).toString())
        .get();
  }

  void moneyUp(String uid) async {
    //출석 때 사용자의 돈을 추가하여 데이터베이스에 저장하는 함수
    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.collection("users").doc(uid);

    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
    int m = documentSnapshot.get('money');
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"money": m + 10});
  }

  Future<void> _taskDelete(String uid, String id) async {
    //to-do 삭제하는 함수
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '삭제 확인창',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              //List Body를 기준으로 Text 설정
              children: <Widget>[
                //삭제 확인창으로 사용자에게 정말 삭제할 것인지 확인
                Text('정말 삭제하시겠습니까?'),
              ],
            ),
          ),
          actions: [ 
            TextButton(
              //사용자가 취소를 누르면 아무 작업 없이 팝업창을 나감
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              //삭제를 누르면 데이터베이스에서 삭제후 팝업창을 나감
              child: const Text('삭제'),
              onPressed: () {
                setState(() {
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid)
                      .collection("To-do list")
                      .doc(id)
                      .delete();
                  Navigator.of(context).pop();
                });
              },
            ),
           
          ],
        );
      },
    );
  }

  Future<void> _taskUpdate(String uid, String id, bool state) async {
    //to-do의 isComplete를 토글하여 업데이트하는 함수
    if (state == true) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("To-do list")
          .doc(id)
          .update({'isComplete': false});
    } else {
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("To-do list")
          .doc(id)
          .update({'isComplete': true});
    }
  }

  Future<void> attenCheck(String uid) async {
    //출석체크를 확인시키는 팝업창을 출력하는 함수
    //-> 출석에 성공함 or 이미 출석하였음을 출력
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        String date = DateFormat('yyyy-MM-dd', 'ko').format(_today).toString();
        if (dayMap.containsKey(date)) {
          //이미 해당날짜로 출석정보가 있을 경우, 이미 출석한 상태
          return const AlertDialog(
            title: Text(
              '이미 출석하였습니다.',
              style: TextStyle(fontSize: 20),
            ),
          );
        } else {
          //출석정보를 데이터베이스에 저장
          FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .collection("Attendance")
              .doc(date)
              .set({"date": date});
          moneyUp(uid);
          return const AlertDialog(
            title: Text(
              '출석 성공',
              style: TextStyle(fontSize: 20),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('10포인트 획득'),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _makeMap(var list) async {
    //리스트를 맵으로 변환하는 함수
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await list?.get();
    setState(() {
      for (var doc in querySnapshot.docs) {
        dayMap[doc.id] = doc.id;
      }
    });
  }
}
