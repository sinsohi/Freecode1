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
  final double count;
  final Color color;
  final String category;

  PieModel({
    required this.count,
    required this.color,
    required this.category,
  });
}


class graph extends StatefulWidget {
  const graph({super.key});

  @override
  State<graph> createState() => _graphState();
}

class _graphState extends State<graph> {
    /* final DatabaseReference expenseRef =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference().child('expenses');
  final DatabaseReference incomeRef =
      // ignore: deprecated_member_use
      FirebaseDatabase.instance.reference().child('incomes'); */
  late User? user;
  late String uid;
  late DatabaseReference expenseRef;
  late DatabaseReference incomeRef;
  double totalExpenses = 0.0;
  double totalincomes = 0.0;
  List<Map<String, dynamic>> expensesList = [];
  List<Map<String, dynamic>> incomesList = [];
  Future<List<Map<String, dynamic>>>? expensesFuture;
  late Future<List<Map<String, dynamic>>> incomesFuture;


   Map<String, double> calculateDailyExpenses(List<Map<String, dynamic>> expenses) {
    Map<String, double> dailyExpenses = {};

    for (var expense in expenses) {
      String date = expense['date']; // 날짜 가져옴
      double amount = (expense['amount'] as num).toDouble(); 

      // 날짜별로 지출 합계를 더함
      dailyExpenses.update(date, (value) => value + amount, ifAbsent: () => amount);
    }
    return dailyExpenses;
  } //일별 지출합계 더하는 함수.
  


   @override
  void initState() {
    super.initState();
    initialize(); //여기서 initialize 함수 호출

    expensesFuture = _loadExpenses();
  }

  Future<void> initialize() async {
    user = FirebaseAuth.instance.currentUser;
    uid = user?.uid ?? 'default';
    // ignore: deprecated_member_use
    expenseRef = FirebaseDatabase.instance.reference().child('expenses').child(uid);
    // ignore: deprecated_member_use
    incomeRef = FirebaseDatabase.instance.reference().child('incomes').child(uid);
  //로그인할때 호출. 현재 로그인 된 사용자 UID 이용해 초기화함.
  
  }
  

    Future<List<Map<String, dynamic>>> _loadExpenses() async {
    List<Map<String, dynamic>> loadedExpenses = [];
     DateTime now = DateTime.now();
     DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
     DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    String firstDayOfMonthString = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
String lastDayOfMonthString = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);

DataSnapshot snapshot = await expenseRef
    .orderByChild('date')
    .startAt(firstDayOfMonthString)
    .endAt(lastDayOfMonthString)
    .get(); //이번달 시작, 끝 날짜 계산 후 문자열 변환해 이번 달 지출데이터 모두 가져옴

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

    return loadedExpenses; //지출 데이터 맵 형태로 가져옴.
  }

  double calculateTotalExpensesForCurrentMonth(List<Map<String, dynamic>> expenses) {
    DateTime now = DateTime.now();
  DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
  DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

  double total = 0.0;

  for (var expense in expenses) {
    DateTime expenseDate = DateTime.parse(expense['date']);
   // 지출 날짜가 현재 달 내에 있는지 확인
    if (expenseDate.isAfter(firstDayOfMonth) && expenseDate.isBefore(lastDayOfMonth)) {
      total += (expense['amount'] as num).toDouble();
    }
  }
  return total;
} //현재 월의 모든 지출 합계를 계산

  List<PieModel> generatePieChartData(List<Map<String, dynamic>> expenses) {
  double totalExpenses = calculateTotalExpensesForCurrentMonth(expenses);
  

  //totalExpenses와 expenses를 활용하여 동적으로 PieModel을 생성
  List<PieModel> model =  []; 
  Map<String, double> categoryExpenses = calculateCategoryExpenses(expenses);

  for (var entry in categoryExpenses.entries) {
    double percentage = (entry.value / totalExpenses) * 100;
    model.add(PieModel(count: percentage, color: getCategoryColor(entry.key), category: entry.key,)); // 카테고리 이름을 할당
  }

  return model;
} //count 수정

Color getCategoryColor(String category) {
  // 각 카테고리에 대한 색상을 정의하여 반환하는 함수
  switch (category) {
    case 'food':
      return Color.fromARGB(255, 44, 183, 92).withOpacity(1); // 음식 카테고리의 색상을 빨강으로 지정
    case 'traffic':
      return Color.fromARGB(255, 253, 225, 14).withOpacity(1); // 교통 카테고리의 색상을 주황으로 지정
    case 'leisure':
      return Color.fromARGB(255, 112, 245, 255).withOpacity(1); // 여가 카테고리의 색상을 노랑으로 지정
    case 'shopping':
      return  Color.fromARGB(255, 255, 199, 44).withOpacity(1); // 쇼핑 카테고리의 색상을 초록으로 지정
    case 'etc':
      return  Color.fromARGB(255, 214, 214, 214).withOpacity(1); // 기타 카테고리의 색상을 회색으로 지정
    default:
      return const Color.fromARGB(255, 0, 0, 0); // 기본적으로는 검정 색상을 반환
  }
}


    static const category = ['food', 'traffic', 'leisure', 'shopping', 'etc'];

  Map<String, List<Map<String, dynamic>>> groupExpensesByCategory(
      List<Map<String, dynamic>> expenses) {
    Map<String, List<Map<String, dynamic>>> groupedExpenses = {
      for (var category in category.where((c) => c != 'etc'))
        category: expenses.where((e) => e['category'] == category).toList(),
    };

    groupedExpenses['etc'] = expenses
        .where((e) => !category.where((c) => c != 'etc').contains(e['category']))
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
  List<PieModel> model = generatePieChartData(expensesList);
  
    
    return Scaffold(
      backgroundColor: Color(0xFFF8F6E8),
      appBar: AppBar(
    title: Text('$currentMonth'),
    backgroundColor: Color(0xFF37736C), 
    ), //상단
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [  //여기부터는 디버깅(출력) 위한 파트
          FutureBuilder<List<Map<String, dynamic>>>(
  future: expensesFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      List<Map<String, dynamic>> expenses = snapshot.data ?? [];
List<Widget> expenseTextWidgets = [];
Map<String, double> categoryTotalExpenses = {};

for (var expense in expenses) {
  String category = expense['category'];
  double amount = (expense['amount'] as num).toDouble();

  // 카테고리별 합계 계산
  categoryTotalExpenses[category] =
      (categoryTotalExpenses[category] ?? 0.0) + amount;
}

// 카테고리별 합계를 텍스트로 추가
categoryTotalExpenses.forEach((category, total) {
  expenseTextWidgets.add(Text('Total $category Expenses: $total'));
});

      // 2. Total Expenses를 출력
      double totalExpenses = calculateTotalExpensesForCurrentMonth(expenses);
      expenseTextWidgets.add(Text('Total Expenses: $totalExpenses'));

      // 3. 카테고리별 지출 비율을 계산하고 출력
      List<PieModel> pieChartData = generatePieChartData(expenses);
      for (var data in pieChartData) {
      double percentage = data.count; // PieModel에서 백분율 계산
      //expenseTextWidgets.add(Text('${data.category}: $percentage'));
       double angle = calculateAngle(percentage); // 각도 계산
        expenseTextWidgets.add(Text('${data.category}: $percentage% (Angle: $angle radians)'));
} 


      // 4. 위젯 반환
      return Column(
        children: expenseTextWidgets,
      );
    } else {
      return CircularProgressIndicator();
    }
  },
),  
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
              top: 20.0, // 여백 및 이동 조절(숫자 커질수록 텍스트 위로 올라감)
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                children: [
            RowItem(color: Color.fromARGB(255, 44, 183, 92).withOpacity(1), label: '음식'),
            RowItem(color: Color.fromARGB(255, 255, 199, 44).withOpacity(1), label: '여가'),
            RowItem(color: Color.fromARGB(255, 253, 225, 14).withOpacity(1), label: '교통'),
            RowItem(color: Color.fromARGB(255, 44, 183, 92).withOpacity(1), label: '쇼핑'),
            //RowItem(color: const Color.fromARGB(255, 214, 214, 214).withOpacity(1), label: '기타'), //비율 가장 큰 지출항목 3개 반영할 계획
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
    
  } //widget build
}
class _PieChart extends CustomPainter {
  final List<PieModel> data;

  _PieChart(this.data);

  // 라디안을 각도로 변환하는 함수
double radiansToDegrees(double radians) {
  return radians * (180 / math.pi);
}
  
  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePaint = Paint()..color = Colors.white;
    Offset offset = Offset(size.width / 2, size.width / 2);
    double radius = (size.width / 2) * 0.65; // 파이차트 크기. 원래 크기의 0.65배 함
    canvas.drawCircle(offset, radius, circlePaint);

    double _startPoint = 0.0;
    
    for (int i = 0; i < data.length; i++) {
  double _startAngle = 2 * math.pi * (data[i].count / 100); //오지게 바꿔도 뭐 안됨..
  double _nextAngle = _startPoint + _startAngle;

   if (_nextAngle > 360) {
     _nextAngle -= 360;
     //여기도 있으나마나
  }

      circlePaint.color = data[i].color;

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.width / 2),
          radius: radius,
        ),
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

double calculateAngle(double percentage) {
  // Percentage를 각도로 변환
  double angle = 360 * (percentage / 100); //아니 이거 맞는데

   //각도를 라디안으로 변환
  double radians = angle * (math.pi / 180);

  return radians;
}

void main()  {
  runApp(MaterialApp(
    home: graph(),
  ));
}     