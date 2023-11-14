import 'package:flutter/material.dart';
import 'calendarPage.dart';
import 'graph.dart';
import 'profilePage.dart';
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
            IconButton(
                onPressed: () {
                  // 그래프 페이지로 이동
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => graph(),
                      ));
                },
                icon: Icon(Icons.bar_chart_sharp)),
            IconButton(
                onPressed: () {
                  // 프로필 페이지로 이동
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => profilePage(),
                      ));
                },
                icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}
