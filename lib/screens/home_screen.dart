import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'game_screen.dart';
import 'signin_screen.dart';
import '../class/task.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final _textController = TextEditingController();
  //List<Task> tasks = [];
  var eventDayMap = <DateTime, List<Task>>{};

  DateTime selectedDay = DateTime.now();
   DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        //앱바 구성
        title: const Text('영단어 사전(test)'),
        centerTitle: true, //타이틀 중앙 위치
        elevation: 0.0, //입체감 없애기
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            onPressed: () {
              print('사람');
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
            accountName: Text(auth.currentUser!.displayName.toString()),
            accountEmail: Text(auth.currentUser!.email.toString()),
            onDetailsPressed: () {}, // 디테일
            decoration: BoxDecoration(
                color: Colors.purple[200],
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
          ),
          ListTile(
            leading: const Icon(Icons.view_list),
            title: const Text('단어장'),
            iconColor: Colors.purple,
            onTap: () {
              print('단어장');
            },
          ),
          ListTile(
            leading: const Icon(Icons.sports_esports),
            title: const Text('게임'),
            iconColor: Colors.purple,
            onTap: () {
              print('게임');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const GameScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('상점'),
            iconColor: Colors.purple,
            onTap: () {
              print('상점');
            },
          ),
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃'),
              iconColor: Colors.purple,
              onTap: () {
                FirebaseAuth.instance.signOut().then((value) {
                  print("Signed Out");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()));
                });
              }),
        ],
      )),
      body: Center(
          child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
            //flex:5,
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime.utc(2021, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
              },
               selectedDayPredicate: (DateTime day) {
                     return isSameDay(selectedDay, day);
        },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                // titleTextFormatter: (date, locale) =>
                //    DateFormat.yMMMMd(locale).format(date),
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
              ),
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
              //텍스트박스
              padding: const EdgeInsets.all(8.0),

              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
                      controller: _textController,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_textController.text == '') {
                        return;
                      } else {
                        setState(() {
                          var task = Task(selectedDay,_textController.text);
                          //tasks.add(task);
                          (eventDayMap[selectedDay] ??=[]).add(task);
                          _textController.clear();
                        });
                      }
                    },
                    child: const Text("추가"),
                  )
                ],
              ),
            ),
            
            /*
            for (var i = 0; i < eventDayMap.length; i++)
              Row(
                children: [
                  Flexible(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero),
                        ),
                      ),
                      onPressed: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_box_outline_blank_rounded),
                            Text(eventDayMap[selectedDay].value);
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                       // tasks.remove(tasks[i]);
                        eventDayMap.remove(eventDayMap[i]);
                      });
                    },
                    child: const Text("삭제"),
                  ),
                ],
              ),
              */
          ])),
    );
  }
}
