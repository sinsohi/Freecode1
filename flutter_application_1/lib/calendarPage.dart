import 'package:flutter/material.dart';

class calendarPage extends StatelessWidget {
  const calendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('calendarPage에 달력 구현'),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: calendarPage(),
  ));
}
