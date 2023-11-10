





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'game_screen.dart';
import 'signin_screen.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
   
  final _textController = TextEditingController();

  DateTime selectedDay = DateTime.now();
   DateTime focusedDay = DateTime.now();
                          
  void _taskAdder(String uid,String work,DateTime date){
     final taskAdd=FirebaseFirestore.instance.collection("users").doc(uid).collection("To-do list").doc();
     taskAdd.set({"work":work,"isComplete":false,"date":DateFormat('yyyy.MM.dd', 'ko')
                              .format(date)
                              .toString()});
    }

  Future<QuerySnapshot> readList(String uid,DateTime date) async {
  return FirebaseFirestore.instance.collection("users").doc(uid).collection("To-do list").where("date",isEqualTo: DateFormat('yyyy.MM.dd', 'ko')
                              .format(date)
                              .toString()).get();                          
}
  Future<void> _taskDelete(String uid,String id) async{
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인창', style: TextStyle(fontSize: 20),),
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
                setState(() {
                  FirebaseFirestore.instance.collection("users").doc(uid).collection("To-do list").doc(id).delete(); 
                Navigator.of(context).pop();
                });          
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ); 
 }

   Future<void> _taskUpdate(String uid,String id,bool state)async{
      if(state==true){
          FirebaseFirestore.instance.collection("users").doc(uid).collection("To-do list").doc(id).update({'isComplete': false});
      }else{
          FirebaseFirestore.instance.collection("users").doc(uid).collection("To-do list").doc(id).update({'isComplete': true});
      }
   
 }

 Future<void> _attendance(var list,DateTime date) async{
     String day=DateFormat('yyyy.MM.dd', 'ko')
                              .format(date)
                              .toString();
      /*
      if(list.doc(day).get().length<=0){
        print("출석 성공");
        list.doc(day).set({"date":day});
      }else{
        print("출석 이미");
      }   
      */
   
 }

  @override
  Widget build(BuildContext context) {
    String uid=auth.currentUser!.email.toString();
    var attemList=FirebaseFirestore.instance.collection("users").doc(uid).collection("Attendance");
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
            accountEmail: Text(uid),
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
                  //this.focusedDay = focusedDay   
                });
              },
               selectedDayPredicate: (DateTime day) {
                     return isSameDay(selectedDay, day);
        },
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
              ),
             // eventLoader: ,
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
                            _taskAdder(uid,_textController.text,selectedDay);
                          _textController.clear();
                        }); 
                      }    
                    },
                    child: const Text("추가"),
                  )
                ],
              ),
            ),
           Expanded(
                child: FutureBuilder<QuerySnapshot>(
                    future: readList(uid,selectedDay),
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
                          bool isComplete=doc.get('isComplete');
                          String id=doc.id;
                          return ListTile(
                            onTap: (){
                              setState(() {
                                 _taskUpdate(uid,id,isComplete);
                              });
                            },
                            trailing: IconButton(
                              icon: const Icon(CupertinoIcons.delete),
                              onPressed: () {
                               _taskDelete(uid,id);      
                              },
                            ),
                            title: Text(
                              work,
                              style: isComplete?
                               const TextStyle(
                                 decoration: TextDecoration.lineThrough,
                                 fontStyle: FontStyle.italic,
                              ): null,
                            )
                            
                          );
                        },
                      );
                    }),
           ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (){
                _attendance(attemList, focusedDay);    
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.purple[300])
                ),
              child: const Text('출석',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
                ),),
              ),
            ),
          ])
          ),
    );
    
  } //build
}
