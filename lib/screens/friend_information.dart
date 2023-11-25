import 'package:flutter/material.dart';


class FriendInfo extends StatefulWidget {
   const FriendInfo({Key? key}) : super(key: key);

  @override
  _FriendInfo createState() => _FriendInfo();
}

class _FriendInfo extends State<FriendInfo> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('친구 정보'),
        backgroundColor: Colors.purple[400],
      ),
      body: const SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              
              
            ],
          ),
        ),
      ),
    );
  }
  //합수 구현


}
