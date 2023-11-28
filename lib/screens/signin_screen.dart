import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/reusable_widgets/reusable_widget.dart';
import 'package:flutter_project/screens/signup_screen.dart';
import 'package:flutter_project/utils/color_utils.dart';

import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late TextEditingController _passwordTextController;
  late TextEditingController _emailTextTextController;
  late FocusNode _emailFocusNode;
  late FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _passwordTextController = TextEditingController();
    _emailTextTextController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _passwordTextController.dispose();
    _emailTextTextController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // 로그인 함수
  void _signIn() async {
    final email = _emailTextTextController.text.trim();
    final password = _passwordTextController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // 사용자에게 필수 입력값이 비어있음을 알리는 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("이메일과 비밀번호를 모두 입력해주세요."),
        ),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 사용자 정보 가져오기
      User? user = userCredential.user;

      if (user != null) {
        // 유저 이름을 포함한 메시지 표시
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${user.displayName}님 로그인에 성공했습니다."),
            duration: const Duration(seconds: 2), // 표시 시간 조절
          ),
        );

        // 홈 화면으로 이동
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } catch (error) {
      // FirebaseAuthException이 발생할 때
      if (error is FirebaseAuthException) {
        // 사용자가 존재하지 않는 경우 또는 비밀번호가 올바르지 않은 경우
        if (error.message?.contains('INVALID_LOGIN_CREDENTIALS') == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("이메일 또는 비밀번호가 올바르지 않습니다."),
            ),
          );
        }
        // 그 외의 에러 처리
        else {
          print("Error ${error.toString()}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${error.toString()}"),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.2,
              20,
              0,
            ),
            child: Column(
              children: <Widget>[
                logoWidget("assets/images/logo1.png"),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField(
                  "이메일 정보를 입력해주세요",
                  Icons.person_outline,
                  false,
                  _emailTextTextController,
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
                  "비밀번호를 입력해주세요",
                  Icons.lock_outline,
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
                signInSignUpButton(context, true, _signIn),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("계정이 없으신가요? ", style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          child: const Text(
            "회원가입",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
