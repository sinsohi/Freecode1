import 'package:flutter/material.dart';

class profilePage extends StatelessWidget {
  const profilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('여기는 profile페이지'),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: profilePage(),
  ));
}
