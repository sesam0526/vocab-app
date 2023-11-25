
import 'package:flutter/material.dart';


class FriendInfo extends StatefulWidget {
   String email='';
   FriendInfo({super.key, required this.email});

  
  @override
  _FriendInfo createState() => _FriendInfo(email: email);
}

class _FriendInfo extends State<FriendInfo> {
  String email='';
  _FriendInfo({required this.email});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 정보'),
        backgroundColor: Colors.purple[400],
      ),
      body:  SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                child: Text(email),
              ),
              
              
            ],
          ),
        ),
      ),
    );
  }
  //합수 구현


}
