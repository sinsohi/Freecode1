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

  Event(this.name);
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
      appBar: AppBar(),
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
          selectedLabelStyle:
              TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle:
              TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
                // 홈 페이지로 이동
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
              leftChevronVisible: false,
              rightChevronVisible: false,
              titleTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xff37736c),
                fontSize: 18,
              ),
              headerPadding: const EdgeInsets.symmetric(vertical: 15.0),
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
                      return Container(
                        width: 200,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10.0), // 이 부분을 수정했습니다.
                          color: const Color(0xff82a282), // 초록색 배경 적용
                        ),
                        margin: const EdgeInsets.all(8.0), // 여백 추가
                        child: Padding(
                          // 텍스트와 사각형 사이에 여백 추가
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'JAL'),
                          ),
                        ),
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
              itemCount: events.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        events[index].name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xfff8f6e8),
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
