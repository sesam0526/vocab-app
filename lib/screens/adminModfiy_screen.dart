import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModifyScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const AdminModifyScreen({
    required this.userId,
    required this.userData,
    Key? key,
  }) : super(key: key);

  @override
  _AdminModifyScreenState createState() => _AdminModifyScreenState();
}

class _AdminModifyScreenState extends State<AdminModifyScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _livesController;
  late TextEditingController _passController;
  late TextEditingController _moneyController;
  late TextEditingController _scoreController;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with the existing user data
    _nicknameController =
        TextEditingController(text: widget.userData['nickname']);
    _livesController =
        TextEditingController(text: widget.userData['lives'].toString());
    _passController =
        TextEditingController(text: widget.userData['pass'].toString());
    _moneyController =
        TextEditingController(text: widget.userData['money'].toString());
    _scoreController =
        TextEditingController(text: widget.userData['score'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 정보 수정'),
        backgroundColor: Colors.purple[400],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display User ID
              Text(
                '사용자 ID: ${widget.userId}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              // Modify Nickname
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
              const SizedBox(height: 16.0),

              // Modify Score
              TextField(
                controller: _scoreController,
                decoration: const InputDecoration(labelText: '게임 점수'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

              // Modify Money
              TextField(
                controller: _moneyController,
                decoration: const InputDecoration(labelText: '보유 포인트'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

              // Modify Lives
              TextField(
                controller: _livesController,
                decoration: const InputDecoration(labelText: '보유 목숨 개수'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

              // Modify Pass
              TextField(
                controller: _passController,
                decoration: const InputDecoration(labelText: '보유 패스 개수'),
              ),
              const SizedBox(height: 16.0),

              // Save Button
              SizedBox(
                width: double.infinity, // Make the button take the full width
                child: ElevatedButton(
                  onPressed: () async {
                    // Call a method to update the user information in Firestore
                    await _updateUserInfo();
                    // Pop the screen to go back to the previous screen (AdminScreen)
                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateUserInfo() async {
    try {
      // Update the user information in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'nickname': _nicknameController.text,
        'lives': int.parse(_livesController.text),
        'pass': int.parse(_passController.text),
        'money': int.parse(_moneyController.text),
        'score': int.parse(_scoreController.text),
        // Add more fields to update as needed
      });

      // Show a success message or handle success as needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보가 성공적으로 수정되었습니다.')),
      );
    } catch (e) {
      // Handle errors and show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보 수정 중 오류가 발생하였습니다.')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers
    _nicknameController.dispose();
    _livesController.dispose();
    _passController.dispose();
    _moneyController.dispose();
    _scoreController.dispose();
    super.dispose();
  }
}
