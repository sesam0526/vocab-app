import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/reusable_widgets/reusable_widget.dart';
import 'package:flutter_project/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController _passwordTextController;
  late TextEditingController _emailTextController;
  late TextEditingController _userNameTextController;
  late FocusNode _userNameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _passwordTextController = TextEditingController();
    _emailTextController = TextEditingController();
    _userNameTextController = TextEditingController();
    _userNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _passwordTextController.dispose();
    _emailTextController.dispose();
    _userNameTextController.dispose();
    _userNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "회원가입",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor("CB2B93"),
              hexStringToColor("9546C4"),
              hexStringToColor("5E61F4"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "유저이름을 입력하세요",
                  Icons.person_outline,
                  false,
                  _userNameTextController,
                  focusNode: _userNameFocusNode,
                  onSubmitted: (_) {
                    _userNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "이메일 정보를 입력하세요",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                  focusNode: _emailFocusNode,
                  onSubmitted: (_) {
                    _emailFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "비밀번호를 입력하세요",
                  Icons.lock_outlined,
                  true,
                  _passwordTextController,
                  focusNode: _passwordFocusNode,
                  onSubmitted: (_) {
                    _passwordFocusNode.unfocus();
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, false, () async {
                  final userName = _userNameTextController.text.trim();
                  final email = _emailTextController.text.trim();
                  final password = _passwordTextController.text;

                  if (userName.isEmpty || email.isEmpty || password.isEmpty) {
                    // 사용자에게 필수 입력값이 비어있음을 알리는 메시지 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("모든 정보를 입력해주세요"),
                      ),
                    );
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(email)
                        .set({
                      "id": email,
                      "nickname": userName,
                      "money": 0,
                      "score": 0,
                      "lives": 3,
                      "pass": 0,
                    });

                    await FirebaseAuth.instance.currentUser?.updateDisplayName(
                      userName,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$userName님 회원가입을 축하합니다."),
                        duration: const Duration(seconds: 2), // 표시 시간 조절
                      ),
                    );

                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  } catch (error) {
                    // Firebase Authentication 또는 Firestore에서 발생한 예외 처리
                    if (error is FirebaseAuthException) {
                      switch (error.code) {
                        case 'email-already-in-use':
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("이미 사용 중인 이메일입니다."),
                            ),
                          );
                          break;
                        case 'weak-password':
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("비밀번호는 6글자 이상이어야 합니다."),
                            ),
                          );
                          break;
                        case 'invalid-email':
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("잘못된 이메일 형식입니다."),
                            ),
                          );
                          break;
                        default:
                          print("Error ${error.toString()}");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: ${error.toString()}"),
                            ),
                          );
                      }
                    } else {
                      // FirebaseAuthException이 아닌 경우에 대한 처리
                      print("Error ${error.toString()}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: ${error.toString()}"),
                        ),
                      );
                    }
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
