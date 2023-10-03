import 'package:flutter/material.dart';

class LearningMode extends StatefulWidget {
  const LearningMode({Key? key}) : super(key: key);

  @override
  _LearningModeState createState() => _LearningModeState();
}

class _LearningModeState extends State<LearningMode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 모드'),
        backgroundColor: Colors.purple,
      ),
      body: const SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }
}
