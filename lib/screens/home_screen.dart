import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'signin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  FirebaseAuth auth = FirebaseAuth.instance;
  final _textController=TextEditingController();
  
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( //앱바 구성
        title:const Text( '영단어 사전(test)'),
        centerTitle: true, //타이틀 중앙 위치
        elevation: 0.0, //입체감 없애기
        backgroundColor:Colors.purple,
        actions: [
          IconButton(
          onPressed: (){print('사람');}, 
          icon: const Icon(Icons.person),)
        ],
      ),
      drawer: Drawer(
        child:ListView(
          children: [
            UserAccountsDrawerHeader( //유저 헤더
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
              ),
              accountName: Text(auth.currentUser!.displayName.toString()), 
              accountEmail: Text(auth.currentUser!.email.toString()),
              onDetailsPressed: (){}, // 디테일
              decoration: BoxDecoration(
                color: Colors.purple[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)
                )),
              ),
               ListTile(
                leading: const Icon(Icons.view_list),
                title: const Text('단어장'),
                iconColor: Colors.purple,
                onTap: () {print('단어장');},
              
              ),
               ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('달력'),
                iconColor: Colors.purple,
                onTap: () {
                      print('달력');
                      
                },
              
              ),
               ListTile(
                leading: const Icon(Icons.sports_esports),
                title: const Text('게임'),
                iconColor:Colors.purple,
                onTap: () {print('게임');},
                
              ),
               ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('상점'),
                iconColor: Colors.purple,
                onTap: () {print('상점');},
                
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
                }
              ),
          ],
        )
      ),
    body:Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Flexible(
            flex:5,
            child: TableCalendar(
               locale: 'ko_KR',
               firstDay: DateTime.utc(2021, 10, 16),
               lastDay: DateTime.utc(2030, 3, 14),
               focusedDay: DateTime.now(),

               headerStyle: HeaderStyle(
                titleCentered: true,
                 titleTextFormatter: (date, locale) =>
              DateFormat.yMMMMd(locale).format(date),
              formatButtonVisible: false,
              titleTextStyle: const TextStyle(
            fontSize: 20.0,
          ),
              leftChevronIcon: const Icon(
            Icons.arrow_left,
            size: 40.0,
          ),
          rightChevronIcon: const Icon(
            Icons.arrow_right,
            size: 40.0,
          ),
               ),
      ),),
          Flexible(
            flex:2,
            child: Container(
              color: Colors.blue,)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: 
             Row(
                children: [
                  Flexible(
                     flex:1,
                    child: TextField(
                      controller: _textController,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Add"),
                  )
                ],
              ),
            ),
      ]))
    );
  }
}
