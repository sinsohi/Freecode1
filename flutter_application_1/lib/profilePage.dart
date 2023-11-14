import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class profilePage extends StatelessWidget {
  const profilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: IconButton(
          onPressed: () {
            //로그아웃 버튼
            FirebaseAuth.instance.signOut();
            Navigator.pop(context);
          },
          icon: Icon(Icons.exit_to_app_sharp,
              color: const Color.fromARGB(255, 8, 8, 8)),
        ));
  }
}

void main() {
  runApp(MaterialApp(
    home: profilePage(),
  ));
}
