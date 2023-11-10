import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'calendarPage.dart';
// import 'package:flutterfire_ui/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              //로그아웃 버튼
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.exit_to_app_sharp, color: Colors.white),
          )
        ],
      ),
      body: Center(
        child: Text('Home',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  // 캘린더 페이지로 이동
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => calendarPage(),
                      ));
                },
                icon: Icon(Icons.calendar_month)),
            Icon(Icons.home),
            Icon(Icons.bar_chart_sharp)
          ],
        ),
      ),
    );
  }
}
