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
import 'package:firebase_core/firebase_core.dart'; //파이어베이스 초기화..?



final String currentMonth = DateFormat('MMMM').format(DateTime.now());

class RowItem extends StatelessWidget {
  final Color color;
  final String label;
  final TextStyle textStyle; // 새롭게 추가된 textStyle 속성

  RowItem({required this.color, required this.label, required this.textStyle});


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

  @override
  String toString() {
    return 'PieModel(category: $category, count: $count, color: $color)';
  }
}


class graph extends StatefulWidget {
  const graph({super.key});

  @override
  State<graph> createState() => _graphState();
}


class _graphState extends State<graph> {
  late User? user;
  late String uid;
  DatabaseReference? expenseRef;
  DatabaseReference? incomeRef;
  double totalExpenses = 0.0;
  double totalincomes = 0.0;
  List<Map<String, dynamic>> expensesList = [];
  List<Map<String, dynamic>> incomesList = [];
  List<Map<String, dynamic>> expenses = [];
  late Future<List<Map<String, dynamic>>>? expensesFuture;
  late Future<List<Map<String, dynamic>>> incomesFuture;
  late List<PieModel> model;
  
   @override
  void initState() {
    super.initState();
    
    initialize(); //여기서 initialize 함수 호출
    
  }

  Future<void> initialize() async {
    user = FirebaseAuth.instance.currentUser;
    uid = user?.uid ?? 'default';
    // ignore: deprecated_member_use
    expenseRef = FirebaseDatabase.instance.reference().child('expenses').child(uid);
    // ignore: deprecated_member_use
    incomeRef = FirebaseDatabase.instance.reference().child('incomes').child(uid);
  //로그인할때 호출. 현재 로그인 된 사용자 UID 이용해 초기화함.
  
    /* await _loadExpenses(); //추가
    print('Loaded Expenses: $expenses'); // 로딩된 expenses 출력 */
    expensesFuture = _loadExpenses();
    expenses = (await expensesFuture)!;

    // 카테고리별 지출 계산
  Map<String, double> categoryExpenses = await calculateCategoryExpenses();
  print('Category Expenses: $categoryExpenses');

     print('엥 여기선 나오나 Loaded Expenses: $expenses');
    expensesFuture = _loadExpenses();
}

Future<List<Map<String, dynamic>>> _loadExpenses() async {
  List<Map<String, dynamic>> loadedExpenses = [];
  DateTime now = DateTime.now();
  DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
  DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

  String firstDayOfMonthString = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
  String lastDayOfMonthString = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);

  DataSnapshot snapshot = await expenseRef!
      .orderByChild('date')
      .startAt(firstDayOfMonthString)
      .endAt(lastDayOfMonthString + '\uf8ff') // Unicode character 'uffff'를 추가하여 범위 끝을 지정
      .get();

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
  } else {
    print('Values is null');
  }

  return loadedExpenses;
}


    
Future<double> calculateTotalExpensesForCurrentMonth() async {
  // 데이터 로드
  List<Map<String, dynamic>> expenses = await _loadExpenses();

  DateTime now = DateTime.now();
  DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
  DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

  double total = 0.0;

  for (var expense in expenses) {
    DateTime expenseDate = DateTime.parse(expense['date']);
    
    // 지출 날짜가 현재 달 내에 있는지 확인
    if (expenseDate.isAfter(firstDayOfMonth.subtract(Duration(seconds: 1))) &&
        expenseDate.isBefore(lastDayOfMonth.add(Duration(seconds: 1)))) {
      total += (expense['amount'] as num).toDouble();
    }
  }

  print('Total Expenses휴 해결~: $total'); // 계산된 total 확인

  return total;
}



//여기서 엄청 바꿔씀
Future<Map<String, double>> calculateDailyExpenses() async {
  // 데이터 로드
  List<Map<String, dynamic>> expenses = await _loadExpenses();
  
  Map<String, double> dailyExpenses = {};
  print('순찌먹고싶다: $expenses');


  for (var expense in expenses) {
    String date = expense['date']; // 날짜 가져옴
    double amount = (expense['amount'] as num).toDouble(); 

    // 날짜별로 지출 합계를 더함
    if (dailyExpenses.containsKey(date)) {
      double newValue = dailyExpenses[date]! + amount;
      print('Date: $date, Updated Value: $newValue');
      dailyExpenses[date] = newValue;
    } else {
      print('Date: $date, Initial Value: $amount');
      dailyExpenses[date] = amount;
    }
  }

  return dailyExpenses; //일별 지출 합계 계산
}


Future<List<HorizontalDetailsModel>> generateBarChartData() async {
  Map<String, double> dailyExpenses = await calculateDailyExpenses();

  List<HorizontalDetailsModel> barChartData = [];
  DateTime now = DateTime.now();
  int lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;

  for (int day = 1; day <= lastDayOfMonth; day++) {
    String dateString = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, day));

    double expenseAmount = dailyExpenses.containsKey(dateString)
        ? dailyExpenses[dateString]!
        : 0.0;

    print('막대그래프 Day: $day, Expense Amount: $expenseAmount');

    if (expenseAmount > 0) {
      barChartData.add(
        HorizontalDetailsModel(
          name: '$day일',
          color: Color(0xFF37736C),
          size: expenseAmount,
          sizeTwo: expenseAmount,
          colorTwo: Color(0xFF37736C),
        ),
      );
    }
  }

  return barChartData;
}//막대그래프

Future<List<PieModel>> generatePieChartData() async {
  double totalExpenses = await calculateTotalExpensesForCurrentMonth();
  Map<String, double> categoryExpenses = await calculateCategoryExpenses();

  List<PieModel> model = [];

  DateTime now = DateTime.now();
  String currentMonth = DateFormat('yyyy-MM').format(now);

  categoryExpenses.forEach((category, amount) {
    if (amount > 0) {
      double percentage = totalExpenses != 0.0 ? (amount / totalExpenses * 100) : 0.0;

      model.add(PieModel(
        count: percentage,
        color: getCategoryColor(category),
        category: category,
      ));
    }
  });

  print('돼라돼라 total Expenses: $totalExpenses');
  print('진짜됨 ㄹㅇCategory Expenses: $categoryExpenses');
  print(model);

  return model;
}




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

 Future<Map<String, double>> calculateCategoryExpenses() async {
  // 데이터 로드
  List<Map<String, dynamic>> loadedExpenses = await _loadExpenses();

  // 지출을 카테고리로 그룹화하고 계산
  var groupedExpenses = groupExpensesByCategory(loadedExpenses);

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
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7, //파이차트의 높이
              child: FutureBuilder<List<PieModel>>(
                future: generatePieChartData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    List<PieModel> model = snapshot.data ?? [];

                    return CustomPaint(
                      size: Size(
                        MediaQuery.of(context).size.width,
                        200,
                      ),
                      painter: _PieChart(model),
                    );
                  }
                  else {
                    // Future가 완료되지 않았을 때 반환할 위젯
                    return CircularProgressIndicator();
                  }
                }
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
           RowItem(
  color: Color.fromARGB(255, 255, 204, 77).withOpacity(1),
  label: '여가',
  textStyle: TextStyle(
    fontFamily: 'JAL',
  ),
),
RowItem(
  color: Color.fromARGB(255, 77, 212, 230).withOpacity(1),
  label: '교통',
  textStyle: TextStyle(
    fontFamily: 'JAL',
  ),
),
RowItem(
  color: Color.fromARGB(255, 219, 133, 196).withOpacity(1),
  label: '쇼핑',
  textStyle: TextStyle(
    fontFamily: 'JAL',
  ),
),
RowItem(
  color: Color.fromARGB(255, 226, 226, 226).withOpacity(1),
  label: '기타',
  textStyle: TextStyle(
    fontFamily: 'JAL',
  ),
),

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
            child: FutureBuilder<List<HorizontalDetailsModel>>(
            future: generateBarChartData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                List<HorizontalDetailsModel> barChartData = snapshot.data ?? [];

                return SimpleBarChart(
                  makeItDouble: true,
                  listOfHorizontalBarData: barChartData,
                  verticalInterval: 50000,
                  horizontalBarPadding: 20,
                );
              } else {
                return CircularProgressIndicator();
              }
  }
  ),
            )
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
  
  @override
  void paint(Canvas canvas, Size size) {


    Paint circlePaint = Paint()..color = Colors.white;

    Offset offset = Offset(size.width / 2, size.width / 2);
    double radius = (size.width / 2) * 0.65;

    canvas.drawCircle(offset, radius, circlePaint);

    double _startPoint = -math.pi / 2; // 시작 각도를 -π / 2로 초기화

    for (int i = 0; i < data.length; i++) {
      double _startAngle = 2 * math.pi * (data[i].count / 100);
      double _nextAngle = 2 * math.pi * (data[(i + 1) % data.length].count / 100);
      circlePaint.color = data[i].color;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.width / 2), radius: radius),
        _startPoint,
        _startAngle,
        true,
        circlePaint);

      _startPoint += _startAngle;


    
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: graph(),
  ));
}     