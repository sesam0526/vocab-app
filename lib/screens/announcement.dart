import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'announ_detail.dart';
import 'addAnnoun.dart';

class AnnouncementScreen extends StatefulWidget {
  //공지사항 창
  const AnnouncementScreen({Key? key}) : super(key: key);

  @override
  _AnnouncementScreen createState() => _AnnouncementScreen();
}

class _AnnouncementScreen extends State<AnnouncementScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email='';
  @override
  Widget build(BuildContext context) {
  User? currentUser = _auth.currentUser;
  if(currentUser != null){
    email=currentUser.email.toString();
  }
  
 return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.purple[400],
         //사용자가 관리자인 계정(master) 일 때만 뜨는 아이콘, 
        actions: [
         if(email.compareTo('master@gmail.com')==0)
            IconButton(
            onPressed: () async {
              //공지사항을 등록하는 창으로 이동하는 함수
               Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddAnnounScreen( )));
            },
            icon: const Icon(Icons.add_box,color: Colors.white,),
          )
          
          
        ],
      ), //DB에 저장된 공지사항의 title 리스트
       body: StreamBuilder<QuerySnapshot>(
        stream:announList(),
        builder: (context, snapshot) {
          //로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          //데이터 로드 시 오류 발생시
          if (snapshot.hasError) {
            return const Center(child: Text('데이터 로드 중 오류가 발생했습니다.'));
          }
          //공지사항이 없을 경우
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('공지사항이 없습니다.'));
          }
          var announs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: announs.length,
            itemBuilder: (context, index) {
              var announcement = announs[index];
              return ListTile(
                title: Text(announcement['title']),
                onTap: () {
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AnnounDetailScreen(
                    announId: announcement.id,
                    announName: announcement['title'],
                    )));
              },
               // 
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> announList(){
    //DB에 저장되어있는 공지사항 정보를 받아오는 함수
    return FirebaseFirestore.instance
        .collection('Announcement')
        .snapshots();
  }
}