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
          "Sign Up",
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
                  "Enter UserName",
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
                  "Enter Email Id",
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
                  "Enter Password",
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
                signInSignUpButton(context, false, () {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _emailTextController.text,
                    password: _passwordTextController.text,
                  )
                      .then((value) async {
                    print("Created New Account");
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(_emailTextController.text)
                        .set({
                      "id": _emailTextController.text,
                      "nickname": _userNameTextController.text,
                      "money": 0,
                      "score": 0,
                    });
                    await FirebaseAuth.instance.currentUser
                        ?.updateDisplayName(_userNameTextController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  }).onError((error, stackTrace) {
                    print("Error ${error.toString()}");
                  });
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
