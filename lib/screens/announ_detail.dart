import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnnounDetailScreen extends StatefulWidget {
  //공지사항 내용 창
  final String announId;
  final String announName;
  const AnnounDetailScreen({Key? key, required this.announId, required this.announName}) : super(key: key);

  @override
  _AnnounDetailScreen createState() => _AnnounDetailScreen();
}

class _AnnounDetailScreen extends State<AnnounDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email='';
  String mainText='';

  @override
  Widget build(BuildContext context) {
  User? currentUser = _auth.currentUser;
  if(currentUser != null){
    email=currentUser.email.toString();
  }
  getAnnounDetail(widget.announId);
 return Scaffold(
      appBar: AppBar(
        title: Text(widget.announName),
        backgroundColor: Colors.purple[400],
         //사용자가 관리자인 계정(master) 일 때만 뜨는 아이콘, 
        actions: [
         if(email.compareTo('master@gmail.com')==0)
            IconButton(
            onPressed: (){
              //공지사항을 삭제확인창 호출
              showDeleteDialog(widget.announId);
            },
            icon: const Icon(CupertinoIcons.delete,color: Colors.white,),
          )
          
          
        ],
      ), //DB에 저장된 공지사항의 title 리스트
       body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5.0),
               width: double.infinity,
                height: 50,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.black, width: 1))),
              child: Text(widget.announName,style: const TextStyle(fontSize: 25),textAlign: TextAlign.center),
              ),
              const Padding(padding: EdgeInsets.all(5.0)),
            Text(mainText,style: const TextStyle(fontSize: 15),)

          ],
        ),)
      
    );
  }

Future<void> getAnnounDetail(String id) async{
    //해당 공지사항문서 id로 공지사항 내용 불러오기
     DocumentSnapshot<Map<String, dynamic>> query =
        await FirebaseFirestore.instance.collection('Announcement').doc(id).get();
    if(query.data()!=null){
       if (mounted) {
      setState(() {
        mainText = query.data()!['main text'];
      });
    }
    }
   
  }
  
  void showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '삭제 확인창',
            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            // 스크롤 화면
            child: Text('정말 삭제하시겠습니까?'),
          ),
           actions: [
            TextButton(
              //삭제를 누르면 데이터베이스에서 삭제후 팝업창을 나감
              child: const Text('삭제'),
              onPressed: () {
                setState(() {
                 FirebaseFirestore.instance.collection('Announcement').doc(id).delete();
                  Navigator.of(context).pop();
                   Navigator.of(context).pop();
                   ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공지사항을 삭제하였습니다.'),
          ),
        );
                });
              },
            ),
            TextButton(
              //관리자가 취소를 누르면 아무 작업 없이 팝업창을 나감
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
/*
Future<void> deleteAnnounDetail(String id) async{
    //해당 공지사항문서 삭제하기, 관리자 전용함수
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 다이얼로그 이외의 바탕 눌러도 안꺼지도록 설정
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text(
            '삭제 확인창',
            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
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
              //삭제를 누르면 데이터베이스에서 삭제후 팝업창을 나감
              child: const Text('삭제'),
              onPressed: () {
                setState(() {
                 FirebaseFirestore.instance.collection('Announcement').doc(id).delete();
                  Navigator.of(context).pop();
                });
              },
            ),
            TextButton(
              //관리자가 취소를 누르면 아무 작업 없이 팝업창을 나감
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
*/

  
}