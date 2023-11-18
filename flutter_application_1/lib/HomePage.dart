// ignore_for_file: unused_local_variable, duplicate_ignore, file_names, library_private_types_in_public_api, deprecated_member_use, avoid_unnecessary_containers

import 'dart:async';

import 'package:flutter/material.dart';
import 'calendarPage.dart';
import 'graph.dart';
import 'profilePage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference expenseRef =
      FirebaseDatabase.instance.reference().child('expenses');
  double totalExpenses = 0.0;
  List<Map<String, dynamic>> expensesList = [];
  Future<List<Map<String, dynamic>>>? expensesFuture;

  @override
  void initState() {
    super.initState();
    expensesFuture = _loadExpenses();
  }

  Future<void> addExpense(String type, DateTime date, String category, String itemName, double amount) async {
    await expenseRef.push().set({
      'type': type,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'category': category,
      'itemName': itemName,
      'amount': amount,
    });
    setState(() {
      expensesFuture = _loadExpenses();
    });
  }

Future<List<Map<String, dynamic>>> _loadExpenses() async {
  List<Map<String, dynamic>> loadedExpenses = [];
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 오늘 날짜를 yyyy-MM-dd 형식의 문자열로 변환

  DataSnapshot snapshot = await expenseRef.orderByChild('date').equalTo(today).get();

  if (snapshot.value != null) {
    Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

    if (values != null) {
      values.forEach((key, value) {
        loadedExpenses.add({
          'type': value['type'],
          'amount': value['amount'],
          'date': value['date'],
        });
      });
    }
  }

  return loadedExpenses;
}










  double _calculateTotalExpenses(List<Map<String, dynamic>> expenses) {
    double total = 0.0;
    for (var expense in expenses) {
      total += double.parse(expense['amount'].toString());
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(55, 115, 108, 2),
          title: Container(
            child: Row(
              children: const [
                Icon(Icons.account_circle, color: Color.fromRGBO(248, 246, 232, 1), size: 50,),
                SizedBox(width: 10),
                Text(
                  'welcome!',
                  style: TextStyle(
                    color: Color.fromRGBO(248, 246, 232, 1),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          color: Color.fromRGBO(248, 246, 232, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: double.infinity, height: 30,),
              Container(color: Color.fromRGBO(55, 115, 108, 1), width: double.infinity, height: 300,
                child: Column(
                  children: [
                    Container(color: Color.fromRGBO(100, 115, 108, 1), width: double.infinity, height: 100,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _showExpenseDialog(context),
                            child: Text('지출 추가'),
                          ),
                          ElevatedButton(
                            onPressed: () => _showIncomeDialog(context),
                            child: Text('수입 추가'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text('오늘의 지출 내역'),
              Text('항목별 지출 금액'),
              // ...

FutureBuilder<List<Map<String, dynamic>>>(
          future: expensesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              double total = _calculateTotalExpenses(snapshot.data ?? []);
              return Text('오늘의 지출 합계: $total');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),

// ...

            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Colors.grey,
                blurRadius: 15,
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Color.fromRGBO(55, 115, 108, 1),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color.fromRGBO(248, 246, 232, 1),
            unselectedItemColor: Color.fromRGBO(248, 246, 232, 1),
            selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: '캘린더',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_sharp),
                label: '통계자료',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: '마이페이지',
              ),
            ],
            onTap: (int index) {
              switch (index) {
                case 0:
                  // 홈 페이지로 이동 (아직 구현되지 않음)
                  break;
                case 1:
                  // 캘린더 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => calendarPage()),
                  );
                  break;
                case 2:
                  // 통계자료 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => graph()),
                  );
                  break;
                case 3:
                  // 마이페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => profilePage()),
                  );
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showExpenseDialog(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    String category = '';
    String itemName = '';
    double amount = 0.0;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('지출 추가'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            primaryColor: Color.fromRGBO(55, 115, 108, 1),
                            hintColor: Color.fromRGBO(55, 115, 108, 1),
                            colorScheme: ColorScheme.light(primary: Color.fromRGBO(55, 115, 108, 1)),
                            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (date != null && date != selectedDate) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 10),
                      Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                      ),
                    ],
                  ),
                ),
                TextField(
                  decoration: InputDecoration(labelText: '지출 항목'),
                  onChanged: (text) {
                    setState(() {
                      category = text;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: '지출 내역 이름'),
                  onChanged: (text) {
                    setState(() {
                      itemName = text;
                    });
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: '지출 금액'),
                  keyboardType: TextInputType.number,
                  onChanged: (text) {
                    setState(() {
                      amount = double.parse(text);
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                addExpense(
                  '지출',
                  selectedDate,
                  category,
                  itemName,
                  amount,
                );
                Navigator.of(context).pop();
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showIncomeDialog(BuildContext context) async {
    // 구현이 필요함
  }
}
