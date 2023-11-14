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
        backgroundColor: Color.fromRGBO(55, 115, 108, 1),
        title: Container(
          child: Row(
            children: [
              Icon(
                Icons.account_circle,
                color: Color.fromRGBO(248, 246, 232, 1),
                size: 50,
              ),
              SizedBox(width: 10), //아이콘이랑 글자사이의 공백을 조절하기 위한 박스얌
              Text(
                'welcome!',
                style: TextStyle(
                  color: Color.fromRGBO(248, 246, 232, 1),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              // Image.asset(
              //   'img-removebg-preview.png',
              //   fit: BoxFit.cover,
              //   height: 50,
              //   width: 50,
              // ),
            ],
          ),
        ),
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
