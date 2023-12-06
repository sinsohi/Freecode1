// ignore_for_file: unused_local_variable, duplicate_ignore, file_names, library_private_types_in_public_api, deprecated_member_use, avoid_unnecessary_containers, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unused_import

import 'dart:async';
import 'package:flutter/material.dart';
import 'calendarPage.dart';
import 'graph.dart';
import 'profilePage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

void _launchURL() async {
  const url = 'https://www.kfb.or.kr/main/main.php';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class _HomePageState extends State<HomePage> {
  late User? user;
  late String uid;
  late DatabaseReference expenseRef;
  late DatabaseReference incomeRef;

  final List<String> imgList = [
    'assets/1.jpeg',
    'assets/2.jpeg',
    'assets/3.jpeg',
    'assets/4.jpeg',
  ];

  Future<void> initialize() async {
    user = FirebaseAuth.instance.currentUser;
    uid = user?.uid ?? 'default';
    expenseRef =
        FirebaseDatabase.instance.reference().child('expenses').child(uid);
    incomeRef =
        FirebaseDatabase.instance.reference().child('incomes').child(uid);
  }

  double totalExpenses = 0.0;
  double totalincomes = 0.0;
  List<Map<String, dynamic>> expensesList = [];
  List<Map<String, dynamic>> incomesList = [];
  Future<List<Map<String, dynamic>>>? expensesFuture;
  Future<List<Map<String, dynamic>>>? incomesFuture;

  @override
  void initState() {
    super.initState();

    initialize().then((_) {
      setState(() {
        expensesFuture = _loadExpenses();
        incomesFuture = _loadIncomes();
      });
    });
  }

  Future<void> addExpense(String type, DateTime date, String category,
      String itemName, double amount) async {
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

  Future<void> addIncome(DateTime date, double amount) async {
    await incomeRef.push().set({
      'date': DateFormat('yyyy-MM-dd').format(date),
      'amount': amount,
    });
    setState(() {
      incomesFuture = _loadIncomes();
    });
  }

  Future<List<Map<String, dynamic>>> _loadExpenses() async {
    List<Map<String, dynamic>> loadedExpenses = [];
    DateTime now = DateTime.now();
    DateTime firstDayThisMonth = DateTime(now.year, now.month, 1);
    DateTime firstDayNextMonth = DateTime(now.year, now.month + 1, 1);

    String firstDayThisMonthString =
        DateFormat('yyyy-MM-dd').format(firstDayThisMonth);
    String firstDayNextMonthString =
        DateFormat('yyyy-MM-dd').format(firstDayNextMonth);

    DataSnapshot snapshot = await expenseRef
        .orderByChild('date')
        .startAt(firstDayThisMonthString)
        .endAt(firstDayNextMonthString)
        .get();

    if (snapshot.value != null) {
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        values.forEach((key, value) {
          loadedExpenses.add({
            'type': value['type'],
            'amount': value['amount'],
            'date': value['date'],
            'category': value['category'],
          });
        });
      }
    }

    return loadedExpenses;
  }

  Future<List<Map<String, dynamic>>> _loadExpensesToday() async {
    List<Map<String, dynamic>> loadedExpenses = [];
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    DataSnapshot snapshot =
        await expenseRef.orderByChild('date').equalTo(today).get();

    if (snapshot.value != null) {
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        values.forEach((key, value) {
          loadedExpenses.add({
            'type': value['type'],
            'amount': value['amount'],
            'date': value['date'],
            'category': value['category'],
          });
        });
      }
    }

    return loadedExpenses;
  }

  Future<List<Map<String, dynamic>>> _loadIncomes() async {
    List<Map<String, dynamic>> loadedIncomes = [];
    String today = DateFormat('yyyy-MM-dd')
        .format(DateTime.now()); // 오늘 날짜를 yyyy-MM-dd 형식의 문자열로 변환

    DataSnapshot snapshot =
        await incomeRef.orderByChild('date').equalTo(today).get();

    if (snapshot.value != null) {
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        values.forEach((key, value) {
          loadedIncomes.add({
            'amount': value['amount'],
            'date': value['date'],
          });
        });
      }
    }

    return loadedIncomes;
  }

  Future<List<Map<String, dynamic>>> _loadAllExpenses() async {
    List<Map<String, dynamic>> loadedExpenses = [];

    DataSnapshot snapshot = await expenseRef.get();

    if (snapshot.value != null) {
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        values.forEach((key, value) {
          loadedExpenses.add({
            'type': value['type'],
            'amount': value['amount'],
            'date': value['date'],
            'category': value['category'],
          });
        });
      }
    }

    return loadedExpenses;
  }

  Future<List<Map<String, dynamic>>> _loadAllIncomes() async {
    List<Map<String, dynamic>> loadedIncomes = [];

    DataSnapshot snapshot = await incomeRef.get();

    if (snapshot.value != null) {
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        values.forEach((key, value) {
          loadedIncomes.add({
            'amount': value['amount'],
            'date': value['date'],
          });
        });
      }
    }

    return loadedIncomes;
  }

  static const category = ['food', 'traffic', 'leisure', 'shopping', 'etc'];

  Map<String, List<Map<String, dynamic>>> groupExpensesByCategory(
      List<Map<String, dynamic>> expenses) {
    Map<String, List<Map<String, dynamic>>> groupedExpenses = {
      for (var category in category.where((c) => c != 'etc'))
        category: expenses.where((e) => e['category'] == category).toList(),
    };

    groupedExpenses['etc'] = expenses
        .where(
            (e) => !category.where((c) => c != 'etc').contains(e['category']))
        .toList();

    return groupedExpenses;
  }

  Map<String, double> calculateCategoryExpenses(
      List<Map<String, dynamic>> expenses) {
    var groupedExpenses = groupExpensesByCategory(expenses);

    Map<String, double> categoryExpenses = {};
    groupedExpenses.forEach((category, expenses) {
      double total = 0.0;
      for (var expense in expenses) {
        total += (expense['amount'] as num).toDouble();
      }
      categoryExpenses[category] = total;
    });

    return categoryExpenses;
  }

  double _calculateTotalExpenses(List<Map<String, dynamic>> expenses) {
    double total = 0.0;
    for (var expense in expenses) {
      total += (expense['amount'] as num).toDouble();
    }
    return total;
  }

  // ignore: unused_element
  double _calculateTotalIncomes(List<Map<String, dynamic>> incomes) {
    double total = 0.0;
    for (var income in incomes) {
      total += (income['amount'] as num).toDouble();
    }
    return total;
  }

  double _calculateCurrentAsset(
      List<Map<String, dynamic>> incomes, List<Map<String, dynamic>> expenses) {
    double totalIncome = _calculateTotalIncomes(incomes);
    double totalExpense = _calculateTotalExpenses(expenses);
    return totalIncome - totalExpense;
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
                Icon(
                  Icons.account_circle,
                  color: Color.fromRGBO(248, 246, 232, 1),
                  size: 50,
                ),
                SizedBox(width: 10),
                Text(
                  'welcome!',
                  style: TextStyle(
                      color: Color.fromRGBO(248, 246, 232, 1),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'JAL'),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          color: Color.fromRGBO(248, 246, 232, 1), width: double.infinity,
          height: double.infinity, //body를 꽉채우는 container
          child: SingleChildScrollView(
            //화면 해상도에 따라 오류 발생하는 경우를 해결하기 위한 scrollview
            child: Column(
              //큰 배경들 구간 나누기 위한 세로 정렬
              children: [
                Container(
                  //기능 구현 부분 큰 배경 container
                  color: Color.fromRGBO(248, 246, 232, 1),
                  width: double.infinity, height: 350,
                  child: Column(
                    //공간 분할 container들을 세로로 정렬
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        //추가 디자인을 위한 공간
                        width: double.infinity,
                        height: 30,
                        child: Align(alignment: Alignment.bottomRight,
                          child: Text('Start to save your money!           ', style: TextStyle(fontFamily: 'JAL', fontSize: 10,),)),
                      ),
                      Container(
                        //기능 구현 작은 배경 container
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(55, 115, 108, 1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              )
                            ]),
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        margin: EdgeInsets.symmetric(horizontal: 16.0),

                        width: double.infinity,
                        height: 300,
                        child: Column(
                          //작은 배경 안 디자인들 정렬
                          children: [
                            Container(
                              color: Color.fromRGBO(55, 115, 108, 1),
                              width: double.infinity,
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10.0), // 왼쪽 아이콘에 왼쪽 여백 추가
                                    child: Icon(
                                      Icons.circle,
                                      size: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: 10.0), // 오른쪽 아이콘에 오른쪽 여백 추가
                                    child: Icon(
                                      Icons.circle,
                                      size: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              //기능 구현 배경 container
                              color: Color.fromRGBO(55, 115, 108, 1),
                              width: double.infinity,
                              height: 100,
                              child: PageView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  Container(
                                    width: 200,
                                    height: 90,
                                    color: Color.fromRGBO(55, 115, 108, 1),
                                    child: FutureBuilder<
                                        List<Map<String, dynamic>>>(
                                      future: _loadExpensesToday(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          double total =
                                              _calculateTotalExpenses(
                                                  snapshot.data ?? []);
                                          return Center(
                                              child: Column(
                                            children: [
                                              Text(
                                                '< Today Total Expenses >',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontFamily: 'JAL'),
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 20,
                                              ),
                                              Text('$total won',
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      fontFamily: 'JAL')),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 5,
                                              ),
                                              Container(
                                                  width: double.infinity,
                                                  height: 20,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.brightness_1,
                                                        size: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.5),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .brightness_1_outlined,
                                                        size: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.5),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .brightness_1_outlined,
                                                        size: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.5),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ));
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  '에러: ${snapshot.error}'));
                                        } else {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: 200,
                                    height: 90,
                                    color: Color.fromRGBO(55, 115, 108, 1),
                                    child: FutureBuilder<
                                        List<Map<String, dynamic>>>(
                                      future: incomesFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.waiting ||
                                            snapshot.data == null) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else {
                                          double total =
                                              _calculateTotalExpenses(
                                                  snapshot.data ?? []);
                                          return Center(
                                              child: Column(
                                            children: [
                                              Text(
                                                '< Today Total Incomes >',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontFamily: 'JAL'),
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 20,
                                              ),
                                              Text(
                                                '$total won',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontFamily: 'JAL'),
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 5,
                                              ),
                                              Container(
                                                  width: double.infinity,
                                                  height: 20,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .brightness_1_outlined,
                                                        size: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.5),
                                                      ),
                                                      Icon(
                                                        Icons.brightness_1,
                                                        size: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.5),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .brightness_1_outlined,
                                                        size: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.5),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ));
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: 200,
                                    height: 90,
                                    color: Color.fromRGBO(55, 115, 108, 1),
                                    child: FutureBuilder<
                                        List<List<Map<String, dynamic>>>>(
                                      future: Future.wait([
                                        _loadAllIncomes(),
                                        _loadAllExpenses()
                                      ]),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          List<Map<String, dynamic>> incomes =
                                              snapshot.data?[0] ?? [];
                                          List<Map<String, dynamic>> expenses =
                                              snapshot.data?[1] ?? [];
                                          double currentAsset =
                                              _calculateCurrentAsset(
                                                  incomes, expenses);
                                          return Center(
                                              child: Column(
                                            children: [
                                              Text(
                                                '< My Current Assets >',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontFamily: 'JAL'),
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 20,
                                              ),
                                              Text(
                                                '$currentAsset won',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontFamily: 'JAL'),
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 5,
                                              ),
                                              Container(
                                                  width: double.infinity,
                                                  height: 20,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .brightness_1_outlined,
                                                        size: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.5),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .brightness_1_outlined,
                                                        size: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.5),
                                                      ),
                                                      Icon(
                                                        Icons.brightness_1,
                                                        size: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.5),
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ));
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 20,
                            ),
                            Container(
                              color: Color.fromRGBO(55, 115, 108, 1),
                              width: double.infinity,
                              height: 100,
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    color: Color.fromRGBO(
                                        55, 115, 108, 1), //이미지 배경 컨테이너
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 50,
                                          child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Image.asset(
                                                'assets/hmmpiggy.png',
                                                height: 50,
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                        Container(
                                          width: 100,
                                          height: 50,
                                          child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Image.asset(
                                                'assets/hmmpiggy.png',
                                                height: 50,
                                                fit: BoxFit.fill,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 30,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _showExpenseDialog(context),
                                            // ignore: sort_child_properties_last
                                            child: Text(
                                              'Expense',
                                              style: TextStyle(
                                                color: Colors
                                                    .black, // 글자 색상을 검정색으로 변경
                                                fontFamily: 'JAL',
                                              ),
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(
                                                Color.fromRGBO(55, 115, 108, 1),
                                              ), // 버튼 색상을 초록색으로 변경
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  side: BorderSide(
                                                      color: Colors.black,
                                                      width: 2.0), // 테두리 색상 설정
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 100,
                                          height: 30,
                                          child: ElevatedButton(
                                            onPressed: () =>
                                                _showIncomeDialog(context),
                                            // ignore: sort_child_properties_last
                                            child: Text(
                                              'Income',
                                              style: TextStyle(
                                                color: Colors
                                                    .black, // 글자 색상을 검정색으로 변경
                                                fontFamily: 'JAL',
                                              ),
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(
                                                Color.fromRGBO(55, 115, 108, 1),
                                              ), // 버튼 색상을 초록색으로 변경
                                              shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  side: BorderSide(
                                                      color: Colors.black,
                                                      width: 2.0), // 테두리 색상 설정
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      
                    ],
                  ),
                ),
                Container(
                  color: Color.fromRGBO(248, 246, 232, 1), //카테고리 가장 큰  배경 컨테이너
                  width: double.infinity,
                  height: 400,
                  child: Row(
                    children: [
                      Container(
                        width: 200,
                        height: double.infinity,
                        color: Color.fromRGBO(248, 246, 232, 1), // 말풍선 돼지 컨테이너
                        child: Column(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 50,
                            ),
                            Container(
                                height: 100,
                                width: 150,
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/mal.png',
                                      fit: BoxFit.fill,
                                    ),
                                    Container(
                                        width: 150,
                                        height: 50,
                                        child: Center(
                                          child: Text(
                                            'category',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: 'JAL'),
                                          ),
                                        )),
                                  ],
                                )),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                  height: 200,
                                  width: 150,
                                  child: Image.asset(
                                    'assets/coolpiggy.png',
                                    height: 50,
                                    fit: BoxFit.fill,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 300,
                        height: 350,
                        color:
                            Color.fromRGBO(248, 246, 232, 1), //카테고리 별 금액합계 컨테이너
                        child: Container(
                          width: 200,
                          height: double.infinity,
                          child: Center(
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: expensesFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  Map<String, double> categoryExpenses =
                                      calculateCategoryExpenses(
                                          snapshot.data ?? []);
                                  return Column(
                                    children:
                                        categoryExpenses.entries.map((entry) {
                                      return Container(
                                        width: 250, height: 50,
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(55, 115, 108, 1),
                                          border: Border.all(
                                              color: Colors.black, width: 3),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        margin:
                                            const EdgeInsets.all(8.0), // 여백 추가

                                        child: Padding(
                                          // 텍스트와 사각형 사이에 여백 추가
                                          padding: const EdgeInsets.all(10.0),
                                          child: Center(
                                            child: Text(
                                              '${entry.key}: ${entry.value}',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontFamily: 'JAL'),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ), // 카테고리 별 지출 구역 큰 배경
                Container(
                  color: Color.fromRGBO(248, 246, 232, 1),
                  width: double.infinity,
                  height: 290,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 40,
                        color: Color.fromRGBO(248, 246, 232, 1),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 40,
                              color: Color.fromRGBO(248, 246, 232, 1),
                              child: Center(
                                child: Text(
                                  '>',
                                  style: TextStyle(
                                      fontSize: 25, fontFamily: 'JAL'),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                  width: 450,
                                  height: 40,
                                  color: Color.fromRGBO(248, 246, 232, 1),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '  Financial Product Recommendation',
                                      style: TextStyle(
                                          fontSize: 20, fontFamily: 'JAL'),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                        ),
                        items: imgList
                            .map((item) => Container(
                                  child: Center(
                                    child: Image.asset(item,
                                        fit: BoxFit.cover, width: 1000),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  height: 40,
                  color: Color.fromRGBO(248, 246, 232, 1),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: _launchURL,
                          child: Image.asset(
                            'assets/gul.png',
                            height: 40,
                            width: 40,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: _launchURL,
                          child: Text(
                            'If you want to know more information, click here!',
                            style: TextStyle(fontSize: 10, fontFamily: 'JAL'),
                          ),
                        ),
                      ]),
                ),
              ],
            ),
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
            selectedLabelStyle: TextStyle(
                fontFamily: 'JAL', fontSize: 10, fontWeight: FontWeight.w100),
            unselectedLabelStyle: TextStyle(
                fontFamily: 'JAL', fontSize: 10, fontWeight: FontWeight.w100),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'calendar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_sharp),
                label: 'chart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'my',
              ),
            ],
            onTap: (int index) {
              switch (index) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
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
    List<String> categories = [
      'category',
      'food',
      'traffic',
      'leisure',
      'shopping',
      'etc'
    ];
    String category = categories[0];
    String itemName = '';
    double amount = 0.0;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(248, 246, 232, 1),
              title: Text('expense'),
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
                                colorScheme: ColorScheme.light(
                                    primary: Color.fromRGBO(55, 115, 108, 1)),
                                buttonTheme: ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary),
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
                    DropdownButton<String>(
                      dropdownColor: Color.fromRGBO(248, 246, 232, 1),
                      value: category,
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(
                          color: Color.fromRGBO(1, 1, 1, 1), fontSize: 15),
                      underline: Container(
                        height: 1,
                        color: Color.fromRGBO(1, 1, 1, 0.3),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          category = newValue!;
                        });
                      },
                      items: categories
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                          ),
                        );
                      }).toList(),
                    ),
                    Theme(
                      data: ThemeData(
                        primaryColor: Color.fromRGBO(16, 34, 32, 1), 
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'detail',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(55, 115, 108, 1),
                            ), 
                          ),
                        ),
                        onChanged: (text) {
                          itemName = text;
                        },
                      ),
                    ),
                    Theme(
                      data: ThemeData(
    primaryColor: Color.fromRGBO(55, 115, 108, 1), 
  ),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'account',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(55, 115, 108, 1),
                            ), // 밑줄 색상을 핑크색으로 지정
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (text) {
                          amount = double.parse(text);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    addExpense(
                      'expense',
                      selectedDate,
                      category,
                      itemName,
                      amount,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'add',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showIncomeDialog(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    double amount = 0.0;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Color.fromRGBO(248, 246, 232, 1),
              title: Text('income'),
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
                                colorScheme: ColorScheme.light(
                                    primary: Color.fromRGBO(55, 115, 108, 1)),
                                buttonTheme: ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary),
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
                      decoration: InputDecoration(
                        labelText: 'account',
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(55, 115, 108, 1),
                          ), // 밑줄 색상을 핑크색으로 지정
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        amount = double.parse(text);
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
                  child: Text(
                    'cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    addIncome(
                      selectedDate,
                      amount,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'add',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
