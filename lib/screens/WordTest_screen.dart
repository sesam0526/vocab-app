import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/word_service.dart';
import 'package:provider/provider.dart';

class WordTest extends StatefulWidget {
  const WordTest({Key? key}) : super(key: key);

  @override
  _WordTest createState() => _WordTest();
}

class _WordTest extends State<WordTest> {
  TextEditingController wordController = TextEditingController();
  TextEditingController meaningController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<WordService>(
      builder: (context, wordService,child) {
        User user = FirebaseAuth.instance.currentUser!;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('단어장 만들기'),
            backgroundColor: Colors.purple,
          ),


          body: Column(
            children: [
              /// 입력창
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    /// 텍스트 입력창
                    Expanded(
                      child: TextField(
                        controller: wordController,
                        decoration: InputDecoration(
                          hintText: "단어",
                        ),
                      ),
                    ),
                              /// 텍스트 입력창 (의미)
                    Expanded(
                      child: TextField(
                        controller: meaningController,
                        decoration: InputDecoration(
                          hintText: "의미",
                        ),
                      ),
                    ),

                    
                    /// 추가 버튼
                    ElevatedButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        // create bucket
                        if (wordController.text.isNotEmpty) {
                          wordService.create(wordController.text, meaningController.text, user.uid);
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              Divider(height: 1),

              /// 버킷 리스트
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                    future: wordService.read(user.uid),
                    builder: (context, snapshot) {
                      final documents = snapshot.data?.docs ?? []; // 문서들 가져오기
                      if (documents.isEmpty) {
                        return Center(child: Text("단어가 없습니다."));
                      }
                      return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          String word = doc.get('word');
                          String meaning = doc.get('meaning');
                          return ListTile(
                            title: Text(
                              word,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                            // 삭제 아이콘 버튼
                            trailing: IconButton(
                              icon: Icon(CupertinoIcons.delete),
                              onPressed: () {
                                // 삭제 버튼 클릭시
                                wordService.delete(doc.id);
                              },
                            ),
                          );
                        },
                      );
                    }),
              ),
            ],
          ),









          /*
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              TextField(
                controller: wordController,
                decoration: const InputDecoration(labelText: '단어'),
              ),
              TextField(
                controller: meaningController,
                decoration: const InputDecoration(labelText: '뜻'),
              ),
              ElevatedButton(
                onPressed: () {
                if (wordController.text.isNotEmpty && meaningController.text.isNotEmpty) {
                  wordService.create(wordController.text, meaningController.text, user.uid);
                }

                },
                child: Text('단어 추가'),
              ),
                ]
              ),
            ),
            
          ),
          */



          /*
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: wordController,
                        decoration: const InputDecoration(labelText: '단어'),
                      ),
                    ),
                    
                    ElevatedButton(
                      onPressed: () {
                        if (wordController.text.isNotEmpty && meaningController.text.isNotEmpty) {
                          wordService.create(wordController.text, meaningController.text, user.uid);
                        }           
                      },
                    ),
                  ],
                ),
              ),
              Divider(height : 1),


              Expanded (
                child: FutureBuilder<QuerySnapshot>{
                  future: wordService.read(user.uid),
                  builder: (context, snapshot) {
                    final documents = snapshot.data?.docs ?? [];
                    if (documents.isEmpty) {
                      return Center(child: Text("단어가 없습니다."));
                    }

                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        String word = doc.get('word');
                        //String meaning = doc.get('meaning');
                        return ListTile(
                          title: Text(
                            word,
                            style: const TextStyle(
                              fontSize: 24,
                            ),

                          ),
                          //trailing: IconButton(
                            //icon: Icon(CupertinoIcons.delete),)
                        //)
                        ),
                      },
                    ),
                }),
              )
            ],
          )*/









/*
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // 원 모양 버튼을 눌렀을 때 실행할 코드를 여기에 추가합니다.
              // 예를 들어, 다른 화면으로 이동하는 코드 등을 추가할 수 있습니다.
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.purple, // 버튼의 배경색을 원하는 색상으로 설정할 수 있습니다.
          ),

*/




        );
      },
    );
  }
}
