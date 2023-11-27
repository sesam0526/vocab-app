import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AddAnnounScreen extends StatefulWidget {
  //공지사항 추가 창
  const AddAnnounScreen({Key? key}) : super(key: key);

  @override
  _AddAnnounScreen createState() => _AddAnnounScreen();
}

class _AddAnnounScreen extends State<AddAnnounScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
   final TextEditingController _titleController = TextEditingController();
   final TextEditingController _textController = TextEditingController();
  String mainText='';

  @override
  Widget build(BuildContext context) {
  User? currentUser = _auth.currentUser;
 
 return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항 추가'),
        backgroundColor: Colors.purple[400],
      ), 
       body: SingleChildScrollView(
         
        child: Center(
          child: Column(
            children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '공지사항 타이틀',
              ),
            ),
            const Padding(padding: EdgeInsets.all(5.0)),
            SizedBox(
                  width: double.infinity,
                  child: Flexible(
                    child: TextField(
                      maxLines: null,
              controller: _textController,
              decoration: const InputDecoration(
                labelText: '공지사항 내용',
              ),
              
            ),
                  ), //TextField 크기
                ),               
          ],
          ),

          
          
         
        ),
         
        ),
        floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          //공지사항 저장하고 창 나가기
        if (_textController.text != ''&& _titleController.text!=''){
            uploadAnnoun( _titleController.text,  _textController.text);
          _titleController.clear();
          _textController.clear();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공지사항을 업로드하였습니다.'),
          ),
        );
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('빈 칸으로 업로드할 수 없습니다.'),
          ),
        );
        }
         
        },
        label: const Text(
          '업로드',
          style: TextStyle(fontSize: 20),
        ),
        icon: const Icon(Icons.add),
        )
    );
  }

  Future<void> uploadAnnoun(String name, String text) async {
    //텍스트필드에 적은 내용을 DB에 저장
    await FirebaseFirestore.instance
        .collection('Announcement').doc(DateTime.now().toString()).set({'title':name,'main text':text});
    
  } 

  
}