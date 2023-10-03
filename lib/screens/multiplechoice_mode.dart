import 'package:flutter/material.dart';

class MultipleChoiceMode extends StatefulWidget {
  const MultipleChoiceMode({Key? key}) : super(key: key);

  @override
  _MultipleChoiceModeState createState() => _MultipleChoiceModeState();
}

class _MultipleChoiceModeState extends State<MultipleChoiceMode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('4지선다 모드'),
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
