import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'calendarPage.dart';
import 'graph.dart';
import 'profilePage.dart';
import 'HomePage.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
    home: calendarPage(),
  ));
}

class calendarPage extends StatefulWidget {
  const calendarPage({super.key});

  @override
  State<calendarPage> createState() => _calendarPageState();
}

class Event {
  final String name;
  final String category;
  final String detail;

  Event(this.name, this.category, this.detail);
}

class _calendarPageState extends State<calendarPage> {
  late User? user;
  late String uid;
  late DatabaseReference expenseRef;
  late DatabaseReference incomeRef;

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
        expensesFuture = _loadExpensesForDay(DateTime.now());
        incomesFuture = _loadIncomes();
      });
    });
  }

  DateTime today = DateTime.now();
  Map<DateTime, List<Event>> events = {};
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
      expensesFuture = _loadExpensesForDay(day);
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: content(),
      backgroundColor: Color(0xfff8f6e8),
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
    );
  }

  Future<List<Map<String, dynamic>>> _loadExpensesForDay(DateTime day) async {
    List<Map<String, dynamic>> loadedExpenses = [];
    String dayString = DateFormat('yyyy-MM-dd').format(day);

    DataSnapshot snapshot = await expenseRef
        .orderByChild('date')
        .equalTo(dayString) // 선택한 날짜에 대해 일치하는 지출만 가져옴
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

  Future<List<Map<String, dynamic>>> _loadItemsForCategory(
      String category, DateTime day) async {
    List<Map<String, dynamic>> loadedItems = [];
    String dayString = DateFormat('yyyy-MM-dd').format(day);

    DataSnapshot snapshot =
        await expenseRef.orderByChild('date').equalTo(dayString).get();

    if (snapshot.value != null) {
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        values.forEach((key, value) {
          if (value['category'] == category &&
              value['itemName'] != null &&
              value['amount'] != null) {
            loadedItems.add({
              'itemName': value['itemName'],
              'amount': value['amount'],
            });
          }
        });
      }
    }

    return loadedItems;
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

  Widget content() {
    return ListView(
      children: [
        Container(
          child: TableCalendar(
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: const Color(0xff82a282),
                fontWeight: FontWeight.bold,
              ), // 주중의 스타일 설정
              weekendStyle: TextStyle(
                color: const Color(0xff37736c),
                fontWeight: FontWeight.bold,
              ), // 주말의 스타일 설정
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronVisible: true,
              rightChevronVisible: true,
              titleTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xff37736c),
                fontSize: 18,
              ),
              headerPadding: const EdgeInsets.symmetric(vertical: 35.0),
            ),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            focusedDay: today,
            firstDay: DateTime.utc(2021, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              isTodayHighlighted: false,
              defaultTextStyle: TextStyle(
                color: const Color(0xff37736c),
                fontWeight: FontWeight.bold,
              ),
              weekendTextStyle: TextStyle(
                color: const Color(0xff37736c),
                fontWeight: FontWeight.bold,
              ),
              outsideDaysVisible: false,
              todayTextStyle: const TextStyle(
                color: const Color(0xfff8f6e8),
                fontSize: 16.0,
              ),
              todayDecoration: const BoxDecoration(
                color: const Color(0xff82a282),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: const Color(0xff82a282),
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, dynamic event) {
                if (event.isNotEmpty) {
                  return Container(
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  );
                } else {
                  return Container(); // event가 비어있을 때는 빈 컨테이너 반환
                }
              },
            ),
          ),
        ),

        SizedBox(height: 20),
        _buildEventBanner(),

        Container(
          color: Color(0xfff8f6e8),
          width: double.infinity,
          height: 260,
          padding: EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xff37736c),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                // 테두리 추가
                color: Colors.black, // 테두리 색상 설정
                width: 2, // 테두리 두께 설정
              ),
            ),
            padding: EdgeInsets.all(5.0),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: expensesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  Map<String, double> categoryExpenses =
                      calculateCategoryExpenses(snapshot.data ?? []);
                  return ListView.builder(
                    itemCount: categoryExpenses.length,
                    itemBuilder: (BuildContext context, int index) {
                      var entry = categoryExpenses.entries.elementAt(index);
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: _loadItemsForCategory(entry.key, today),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // 데이터를 불러오는 동안의 처리
                          } else {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Color(0xfff8f6e8),
                                        contentPadding: EdgeInsets.zero,
                                        insetPadding: EdgeInsets.all(
                                            20), // 이 값을 조절하여 전체 AlertDialog 크기 조절
                                        content: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5, // 이 값을 조절하여 가로 크기 조절
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5, // 이 값을 조절하여 세로 크기 조절
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top:
                                                        20), // 이 값을 조절하여 원하는 만큼의 공간을 추가
                                                child: Text(
                                                  'breakdown of expenditure',
                                                  style: TextStyle(
                                                    fontFamily: 'JAL', // 폰트 변경
                                                    fontSize: 17, // 글자 크기 변경
                                                    fontWeight: FontWeight
                                                        .w100, // 글자 굵기 변경
                                                    color: const Color(
                                                        0xff37736c), // 글자 색상 변경
                                                  ),
                                                ),
                                              ),
                                              ...snapshot.data!.map((item) {
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 6), // 원하는 간격으로 조절
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left:
                                                              24.0), // 좌측 여백 추가
                                                      child: Row(
                                                        children: <Widget>[
                                                          Icon(Icons
                                                              .check), // 체크 아이콘 추가
                                                          SizedBox(
                                                              width:
                                                                  10), // 아이콘과 텍스트 사이의 간격 조정
                                                          Text(
                                                            'Item: ${item['itemName']} , Amount: ${item['amount']} won',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'JAL', // 폰트 변경
                                                              fontSize:
                                                                  14, // 글자 크기 변경
                                                              fontWeight: FontWeight
                                                                  .w100, // 글자 굵기 변경
                                                              color: Colors
                                                                  .black, // 글자 색상 변경
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text(
                                              'Close',
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold, // 글자를 두껍게
                                                color: const Color(
                                                    0xff37736c), // 글자 색깔 변경
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  width: 200,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: const Color(0xff82a282),
                                    border: Border.all(
                                      // 테두리 추가
                                      color: Colors.black, // 테두리 색상 설정
                                      width: 2, // 테두리 두께 설정
                                    ),
                                  ),
                                  margin: const EdgeInsets.all(8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      '${entry.key}: ${entry.value}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'JAL',
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ),

        // 카테고리 별 지출 구역 큰 배경
      ],
    );
  }

  Widget _buildEventBanner() {
    List<Event> eventsForSelectedDay = _getEventsForDay(today);

    if (eventsForSelectedDay.isNotEmpty) {
      return Column(
        children: [
          _buildEventList('수입', eventsForSelectedDay),
          SizedBox(height: 20),
          _buildEventList('지출', eventsForSelectedDay),
        ],
      );
    } else {
      return Container(); // 이벤트가 없는 경우 빈 컨테이너 반환
    }
  }

  Widget _buildEventList(String title, List<Event> events) {
    Map<String, List<Event>> categoryEvents = {};
    for (var event in events) {
      if (!categoryEvents.containsKey(event.category)) {
        categoryEvents[event.category] = [];
      }
      categoryEvents[event.category]!.add(event);
    }
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff37736c),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.all(16.0),
      width: 480,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: const Color(0xfff8f6e8),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 150.0,
            decoration: BoxDecoration(
              color: const Color(0xff82a282),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: categoryEvents.keys.length,
              itemBuilder: (BuildContext context, int index) {
                var category = categoryEvents.keys.elementAt(index);
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return FutureBuilder<DataSnapshot>(
                          future: FirebaseDatabase.instance
                              .reference()
                              .child('details')
                              .child(category)
                              .get(), // 카테고리에 해당하는 detail 데이터를 가져옵니다.
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              // 데이터를 가져왔을 때의 처리
                              String detail = snapshot.data!.value.toString();
                              return AlertDialog(
                                title: Text(category),
                                content: Text(detail),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('확인'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator(); // 데이터를 불러오는 동안의 처리
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
