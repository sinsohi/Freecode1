import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:fl_chart/fl_chart.dart';
//import 'package:syncfusion_flutter_charts/charts.dart';
//import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:unique_simple_bar_chart/data_models.dart';
import 'package:unique_simple_bar_chart/horizontal_bar.dart';
import 'package:unique_simple_bar_chart/horizontal_line.dart';
import 'package:unique_simple_bar_chart/simple_bar_chart.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:math' as math;
import 'calendarPage.dart'; //바텀네비게이션바
import 'graph.dart';
import 'profilePage.dart';
import 'package:table_calendar/table_calendar.dart'; // 15~16 현재 월 표시
import 'package:intl/intl.dart'; 
import 'package:firebase_auth/firebase_auth.dart';//데이터베이스 가져오기
import 'package:firebase_database/firebase_database.dart';



final String currentMonth = DateFormat('MMMM').format(DateTime.now());

class RowItem extends StatelessWidget {
  final Color color;
  final String label;

  RowItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10, // 작은 네모 너비 조절
          height: 10, // 작은 네모 높이 조절
          color: color,
        ),
        SizedBox(width: 6), // 네모와 텍스트 간 간격 조절
        Text(label),
      ],
    );
  }
}

class PieModel {
  final int count;
  final Color color;

  PieModel({
    required this.count,
    required this.color,
  });
}


class graph extends StatefulWidget {
  const graph({super.key});

  @override
  State<graph> createState() => _graphState();
}

class _graphState extends State<graph> {
     final DatabaseReference expenseRef =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference().child('expenses');
  final DatabaseReference incomeRef =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference().child('incomes');
  double totalExpenses = 0.0;
  double totalincomes = 0.0;
  List<Map<String, dynamic>> expensesList = [];
  List<Map<String, dynamic>> incomesList = [];
  Future<List<Map<String, dynamic>>>? expensesFuture;
  late Future<List<Map<String, dynamic>>> incomesFuture;

   @override
  void initState() {
    super.initState();
    expensesFuture = _loadExpenses();

  }

    Future<List<Map<String, dynamic>>> _loadExpenses() async {
    List<Map<String, dynamic>> loadedExpenses = [];
    

    DateTime now = DateTime.now(); //여기부터
DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

String firstDayOfMonthString = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
String lastDayOfMonthString = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);

DataSnapshot snapshot = await expenseRef
    .orderByChild('date')
    .startAt(firstDayOfMonthString)
    .endAt(lastDayOfMonthString)
    .get();     //여기까지 이번달 시작, 끝 날짜 계산 후 문자열 변환해 이번 달 지출 데이터 모두 가져옴

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

   static const category = ['음식', '교통', '여가', '쇼핑', '기타'];

  Map<String, List<Map<String, dynamic>>> groupExpensesByCategory(
      List<Map<String, dynamic>> expenses) {
    Map<String, List<Map<String, dynamic>>> groupedExpenses = {
      for (var category in category.where((c) => c != '기타'))
        category: expenses.where((e) => e['category'] == category).toList(),
    };

    groupedExpenses['기타'] = expenses
        .where((e) => !category.where((c) => c != '기타').contains(e['category']))
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
  
  @override
  Widget build(BuildContext context) {
    List<PieModel> model = [
      PieModel(count: 30, color: Color.fromARGB(255, 44, 183, 92).withOpacity(1)),
      PieModel(count: 10, color: Color.fromARGB(255, 253, 225, 14).withOpacity(1)),
      PieModel(count: 30, color: Color.fromARGB(255, 255, 199, 44).withOpacity(1)),
      PieModel(count: 30, color: const Color.fromARGB(255, 214, 214, 214).withOpacity(1)),
    ];
    

    
    return Scaffold(
      backgroundColor: Color(0xFFF8F6E8),
      appBar: AppBar(
    title: Text('$currentMonth'),
    backgroundColor: Color(0xFF37736C), 
    ), //상단
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Container( //원래 Sizedbox였는데 좀 바꿈
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.7, //파이차트의 높이
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  200,),
              painter: _PieChart(model),
            ),
          ),
            ),
          ),
      Expanded(
        flex: 1,
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Positioned(
              left: 400.0, //여백 조절
              top: 20.0, // 여백 및 이동 조절
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                children: [
            RowItem(color: Color.fromARGB(255, 44, 183, 92).withOpacity(1), label: '식비'),
            RowItem(color: Color.fromARGB(255, 255, 199, 44).withOpacity(1), label: '교통'),
            RowItem(color: Color.fromARGB(255, 253, 225, 14).withOpacity(1), label: '쇼핑'),
            RowItem(color: const Color.fromARGB(255, 214, 214, 214).withOpacity(1), label: '기타'), //비율 가장 큰 지출항목 3개 반영할 계획
            //지출항목에 대한 RowItem 추가
          ],
        ),
      ),
          ],
        ),
      ),
   
          //여기에 막대그래프 추가
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,  //123~124 두 줄은 막대그래프 가로 스크롤 위한 것.
              child: Container(
            //막대그래프 코드
            //height: 400, //막대그래프의 높이
        width: MediaQuery.of(context).size.width * 1.5, //막대그래프 가로 크기(0.8이었는데 1.5로 수정)
        child: SimpleBarChart(
          makeItDouble: true,
          listOfHorizontalBarData: [
            HorizontalDetailsModel(
              name: '1일',
              color: const Color(0xFFFBBC05),
              size: 7300,
              sizeTwo: 4000,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '2일',
              color: const Color(0xFFFBBC05),
              size: 9200,
              sizeTwo: 8500,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '3일',
              color: const Color(0xFFFBBC05),
              size: 12000,
              sizeTwo: 10000,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '4일',
              color: const Color(0xFFFBBC05),
              size: 8600,
              sizeTwo: 22000,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '5일',
              color: const Color(0xFFFBBC05),
              size: 6400,
              sizeTwo: 17000,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '6일',
              color: const Color(0xFFFBBC05),
              size: 15500,
              sizeTwo: 12000,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '7일',
              color: const Color(0xFFFBBC05),
              size: 20000,
              sizeTwo: 9600,
              colorTwo: Color(0xFF37736C),
            ),
             HorizontalDetailsModel(
              name: '8일',
              color: const Color(0xFFFBBC05),
              size: 20000,
              sizeTwo: 9600,
              colorTwo: Color(0xFF37736C),
            ),
             HorizontalDetailsModel(
              name: '9일',
              color: const Color(0xFFFBBC05),
              size: 20000,
              sizeTwo: 9600,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '10일',
              color: const Color(0xFFFBBC05),
              size: 20000,
              sizeTwo: 9600,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '11일',
              color: const Color(0xFFFBBC05),
              size: 12000,
              sizeTwo: 10000,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '12일',
              color: const Color(0xFFFBBC05),
              size: 12000,
              sizeTwo: 10000,
              colorTwo: Color(0xFF37736C),
            ),
            
            HorizontalDetailsModel(
              name: '14일',
              color: const Color(0xFFFBBC05),
              size: 12000,
              sizeTwo: 10000,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '15일',
              color: const Color(0xFFFBBC05),
              size: 12000,
              sizeTwo: 10000,
              colorTwo: Color(0xFF37736C),
            ),
            HorizontalDetailsModel(
              name: '16일',
              color: const Color(0xFFFBBC05),
              size: 12000,
              sizeTwo: 10000,
              colorTwo: Color(0xFF37736C),
            ),
          ],
          verticalInterval: 10000, //세로축 눈금 간격
          horizontalBarPadding: 20, //각 막대 사이의 간격 조절
          )
      )
            ),
          ),
          ),
      ],
      ),
      bottomNavigationBar: Container( //여기서부턴 바텀네비게이션바(하단)
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
    )
    );
    
  }
}

class _PieChart extends CustomPainter {
  final List<PieModel> data;

  _PieChart(this.data);
  
  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePaint = Paint()..color = Colors.white;

    Offset offset = Offset(size.width / 2, size.width / 2);
    double radius = (size.width / 2) * 0.65; // 파이 차트 반지름 크기 조절. ex: 0.6은 현재 크기의 60%
    canvas.drawCircle(offset, radius, circlePaint);

    double _startPoint = 0.0;
    for (int i = 0; i < data.length; i++) {
      double _startAngle = 2 * math.pi * (data[i].count / 100);
      double _nextAngle = 2 * math.pi * (data[i].count / 100);
      circlePaint.color = data[i].color;

      canvas.drawArc(
          Rect.fromCircle(
              center: Offset(size.width / 2, size.width / 2), radius: radius),
          -math.pi / 2 + _startPoint,
          _nextAngle,
          true,
          circlePaint);
      _startPoint = _startPoint + _startAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



void main()  {
  runApp(MaterialApp(
    home: graph(),
  ));
}     