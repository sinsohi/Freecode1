import 'package:flutter/material.dart';

class graph extends StatelessWidget {
  const graph({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('여기는 graphPage'),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: graph(),
  ));
}
