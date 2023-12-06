import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unique_simple_bar_chart/data_models.dart';
import 'package:unique_simple_bar_chart/horizontal_bar.dart';
import 'package:unique_simple_bar_chart/horizontal_line.dart';
import 'package:unique_simple_bar_chart/simple_bar_chart.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:math' as math;
import 'calendarPage.dart'; //바텀네비게이션바
import 'graph.dart';
import 'HomePage.dart';
import 'profilePage.dart';
import 'package:table_calendar/table_calendar.dart'; // 15~16 현재 월 표시
import 'package:intl/intl.dart'; 
import 'package:firebase_auth/firebase_auth.dart';//데이터베이스 가져오기
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart'; //파이어베이스 초기화
import 'dart:ui';


final String currentMonth = DateFormat('MMMM').format(DateTime.now());
DateTime now = DateTime.now();
DateTime lastMonth = DateTime(now.year, now.month - 1, now.day);

String formattedLastMonth = DateFormat('MMMM').format(lastMonth);


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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7.0), // 라벨과 다음 라벨 간 간격 조절
          child: Text(
            label,
            style: textStyle, // textStyle 적용
          ),
        ),
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


class _graphState extends State<graph> with TickerProviderStateMixin  {
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
  late AnimationController animationController; // AnimationController 추가
  
  
  @override
  void initState() {
    super.initState();

      initialize(); //여기서 initialize 함수 호출

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200), // 1.2 seconds // 애니메이션 기간을 1.5초로 설정
      
    );

    // 위젯이 화면에 나타난 후 애니메이션 시작
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      startAnimation();
    });
  }
  void startAnimation() {
   if (mounted) {
    animationController.forward();
  }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
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
    expenses = await _loadExpenses(); // 이 부분을 수정

    // 카테고리별 지출 계산
  Map<String, double> categoryExpenses = await calculateCategoryExpenses();
  print('Category Expenses: $categoryExpenses');

     //print('엥 여기선 나오나 Loaded Expenses: $expenses');
    expensesFuture = _loadExpenses();
     setState(() {}); // UI 업데이트를 위해 setState 호출
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

Future<List<Map<String, dynamic>>> _loadLastMonthExpenses() async {
  List<Map<String, dynamic>> loadedLastMonthExpenses = [];
  DateTime now = DateTime.now();
  DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
  DateTime lastDayOfLastMonth = DateTime(now.year, now.month, 0);

  String firstDayOfLastMonthString = DateFormat('yyyy-MM-dd').format(firstDayOfLastMonth);
  String lastDayOfLastMonthString = DateFormat('yyyy-MM-dd').format(lastDayOfLastMonth);

  DataSnapshot snapshot = await expenseRef!
      .orderByChild('date')
      .startAt(firstDayOfLastMonthString)
      .endAt(lastDayOfLastMonthString + '\uf8ff')
      .get();

  Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

  if (values != null) {
    values.forEach((key, value) {
      loadedLastMonthExpenses.add({
        'type': value['type'],
        'amount': value['amount'],
        'date': value['date'],
        'category': value['category'],
      });
    });
  } else {
    print('Values is null');
  }

  return loadedLastMonthExpenses;
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

  //print('Total Expenses휴 해결~: $total'); // 계산된 total 확인

  return total;
}


Future<double> calculateTotalExpensesForLastMonth() async {
  // 데이터 로드
  List<Map<String, dynamic>> expenses = await _loadLastMonthExpenses();

  DateTime now = DateTime.now();
  DateTime firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
  DateTime lastDayOfLastMonth = DateTime(now.year, now.month, 0);

  double LastMonthtotal = 0.0;

  for (var expense in expenses) {
    DateTime expenseDate = DateTime.parse(expense['date']);
    
    // 지출 날짜가 지난 달 내에 있는지 확인
    if (expenseDate.isAfter(firstDayOfLastMonth.subtract(Duration(seconds: 1))) &&
        expenseDate.isBefore(lastDayOfLastMonth.add(Duration(seconds: 1)))) {
      LastMonthtotal += (expense['amount'] as num).toDouble();
    }
  }

  //print('Total Expenses휴 해결~: $LastMonthtotal'); // 계산된 LastMonthtotal 확인

  return LastMonthtotal;
}




//여기서 엄청 바꿔씀
Future<Map<String, double>> calculateDailyExpenses() async {
  // 데이터 로드
  List<Map<String, dynamic>> expenses = await _loadExpenses();
  
  Map<String, double> dailyExpenses = {};
  print('이번달은 순찌먹고싶다: $expenses');


  for (var expense in expenses) {
    String date = expense['date']; // 날짜 가져옴
    double amount = (expense['amount'] as num).toDouble(); 

    // 날짜별로 지출 합계를 더함
    if (dailyExpenses.containsKey(date)) {
      double newValue = dailyExpenses[date]! + amount;
      //print('Date: $date, Updated Value: $newValue');
      dailyExpenses[date] = newValue;
    } else {
      //print('Date: $date, Initial Value: $amount');
      dailyExpenses[date] = amount;
    }
  }

  return dailyExpenses; //일별 지출 합계 계산
}

Future<Map<String, double>> calculateLastMonthDailyExpenses() async {
  // 데이터 로드
  List<Map<String, dynamic>> expenses = await _loadLastMonthExpenses();
  
  Map<String, double> LastMonthdailyExpenses = {};
  print('지난달엔 해물파전 먹고싶었다: $expenses');

  for (var expense in expenses) {
    String date = expense['date']; // 날짜 가져옴
    double amount = (expense['amount'] as num).toDouble(); 

    // 날짜별로 지출 합계를 더함
    if (LastMonthdailyExpenses.containsKey(date)) {
      double newValue = LastMonthdailyExpenses[date]! + amount;
      //print('Date: $date, Updated Value: $newValue');
      LastMonthdailyExpenses[date] = newValue;
    } else {
      //print('Date: $date, Initial Value: $amount');
      LastMonthdailyExpenses[date] = amount;
    }
  }

  return LastMonthdailyExpenses; // 지난 달 일별 지출 합계 계산
}





Future<List<HorizontalDetailsModel>> generateBarChartData() async {
  Map<String, double> dailyExpenses = await calculateDailyExpenses();
  double maxExpense = getMaxExpense(dailyExpenses);

  List<HorizontalDetailsModel> barChartData = [];
  DateTime now = DateTime.now();
  int lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;

  for (int day = 1; day <= lastDayOfMonth; day++) {
    String dateString = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, day));

    double expenseAmount = dailyExpenses.containsKey(dateString)
        ? dailyExpenses[dateString]!
        : 0.0;

    if (expenseAmount > 0) {
      Color barColor = getColorForExpense(expenseAmount, maxExpense);

      barChartData.add(
        HorizontalDetailsModel(
          name: '$day일',
          color: barColor,
          size: expenseAmount,
          sizeTwo: expenseAmount,
          colorTwo: barColor,
        ),
      );
    }
  }

  return barChartData;
}

Future<List<HorizontalDetailsModel>> generateBarChartLastMonthData() async {
  Map<String, double> LastMonthdailyExpenses = await calculateLastMonthDailyExpenses();
  double maxExpense = getMaxExpense(LastMonthdailyExpenses);

  List<HorizontalDetailsModel> barChartLastMonthData = [];
  DateTime now = DateTime.now();
  int lastDayOfLastMonth = DateTime(now.year, now.month, 0).day;

  for (int day = 1; day <= lastDayOfLastMonth; day++) {
    String dateString = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month - 1, day));

    double expenseAmount = LastMonthdailyExpenses.containsKey(dateString)
        ? LastMonthdailyExpenses[dateString]!
        : 0.0;

    if (expenseAmount > 0) {
      Color barColor = getColorForExpense(expenseAmount, maxExpense);

      barChartLastMonthData.add(
        HorizontalDetailsModel(
          name: '$day일',
          color: barColor,
          size: expenseAmount,
          sizeTwo: expenseAmount,
          colorTwo: barColor,
        ),
      );
    }
  }

  return barChartLastMonthData;
}



double getMaxExpense(Map<String, double> dailyExpenses) {
  // 일별 지출 데이터 중 최대값 찾기
  double maxExpense = 0.0;
  dailyExpenses.forEach((_, amount) {
    if (amount > maxExpense) {
      maxExpense = amount;
    }
  });
  return maxExpense;
}

Color getColorForExpense(double expenseAmount, double maxExpense) {
  // 연한 초록색
  final Color startColor = Color(0xFF37736C);
  // 최종 색상
  final Color endColor = Colors.green; // 여기에 원하는 최종 색상을 설정

  // 현재 지출에 대한 비율 계산
  double ratio = expenseAmount / maxExpense;

  // 시작 색상과 끝 색상을 각각 RGB로 변환
  List<int> startRGB = [startColor.red, startColor.green, startColor.blue];
  List<int> endRGB = [endColor.red, endColor.green, endColor.blue];

  // 현재 비율에 따라 RGB 보간 계산
  List<int> resultRGB = [];
  for (int i = 0; i < 3; i++) {
    resultRGB.add((startRGB[i] + (endRGB[i] - startRGB[i]) * ratio).toInt());
  }

  // RGB 값을 사용하여 새로운 Color 생성
  Color resultColor = Color.fromARGB(255, resultRGB[0], resultRGB[1], resultRGB[2]);

  return resultColor;
}


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

  //print('돼라돼라 total Expenses: $totalExpenses');
  //print('진짜됨 ㄹㅇCategory Expenses: $categoryExpenses');
  //print(model);

  return model;
}

Future<List<PieModel>> generatePieChartLastMonthData() async {
  double lastMonthTotalExpenses = await calculateTotalExpensesForLastMonth();
  Map<String, double> categoryLastMonthExpenses = await calculateCategoryLastMonthExpenses();

  List<PieModel> modelLastMonth = [];

  DateTime now = DateTime.now();
  String lastMonth = DateFormat('yyyy-MM').format(DateTime(now.year, now.month - 1, 1));

  categoryLastMonthExpenses.forEach((category, amount) {
    if (amount > 0) {
      double percentage = lastMonthTotalExpenses != 0.0 ? (amount / lastMonthTotalExpenses * 100) : 0.0;

      modelLastMonth.add(PieModel(
        count: percentage,
        color: getCategoryColor(category),
        category: category,
      ));
    }
  });

  return modelLastMonth;
}





Color getCategoryColor(String category) {
  // 각 카테고리에 대한 색상을 정의하여 반환하는 함수
  switch (category) {
    case 'food':
      return Color.fromARGB(255, 129, 201, 134).withOpacity(1); // 음식 카테고리의 색상을 빨강으로 지정
    case 'traffic':
      return Color.fromARGB(255, 175, 246, 255).withOpacity(1); // 교통 카테고리의 색상을 주황으로 지정
    case 'leisure':
      return Color.fromARGB(255, 255, 204, 77).withOpacity(1); // 여가 카테고리의 색상을 노랑으로 지정
    case 'shopping':
      return  Color.fromARGB(255, 219, 133, 196).withOpacity(1); // 쇼핑 카테고리의 색상을 초록으로 지정
    case 'etc':
      return  Color.fromARGB(255, 226, 226, 226).withOpacity(1); // 기타 카테고리의 색상을 회색으로 지정
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


Future<Map<String, double>> calculateCategoryLastMonthExpenses() async {
  // 데이터 로드
  List<Map<String, dynamic>> loadedLastMonthExpenses = await _loadLastMonthExpenses();

  // 지난 달 지출을 카테고리로 그룹화하고 계산
  var groupedLastMonthExpenses = groupExpensesByCategory(loadedLastMonthExpenses);

  Map<String, double> categoryLastMonthExpenses = {};
  groupedLastMonthExpenses.forEach((category, expenses) {
    double total = 0.0;
    for (var expense in expenses) {
      total += (expense['amount'] as num).toDouble();
    }
    categoryLastMonthExpenses[category] = total;
  });

  return categoryLastMonthExpenses;
}







@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFF8F6E8),
    appBar: AppBar(
      title: Text('Expense Stats', style: TextStyle(fontFamily: 'JAL'),
),
      backgroundColor: Color(0xFF37736C),
    ), //상단
    body: Container(width: double.infinity, height: double.infinity,//이거 고정
      child: SingleChildScrollView(
        child: Container(width: double.infinity, height: 650,//이거
          child: PageView(
            scrollDirection: Axis.horizontal,
            children:[
              Container(width: double.infinity, height: 650, color: Color(0xFFF8F6E8),child: expenses.isEmpty ? _buildNoExpensesPage()
                  : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Positioned(
  bottom: 0,
  right: 0,
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
        '$currentMonth                                                                          ',
      style: TextStyle(
        color: const Color.fromARGB(255, 52, 52, 52),
        fontWeight: FontWeight.bold,
        fontSize: 18, // 원하는 크기로 조절
        fontFamily: 'JAL', // 사용할 폰트로 변경
      ),
    ),
  ),
),

                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 5), // 조절하고자 하는 여백 값. 숫자 커질수록 아래로
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
                
                
                              return AnimatedBuilder(
                                        animation: animationController,
                                        builder: (context, child) {
                                           if (animationController.value < 0.1) {
                          return const SizedBox();
                        }
                              return CustomPaint(
                                size: Size(
                                  MediaQuery.of(context).size.width,
                                  200, //파이차트 높이
                                ),
                                painter: _PieChart(model, animationController),
                              );
                            },
                );
                            } else {
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
                        left: 400.0, //여백 조절(숫자 늘리면 오른쪽으로 감)
                        top: 8.0, // 여백 및 이동 조절(숫자 커질수록 텍스트 위로 올라감)
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                          children: [
                            RowItem(
              color: Color.fromARGB(255, 129, 201, 134).withOpacity(1),
              label: 'food',
              textStyle: TextStyle(
              fontFamily: 'JAL',
              fontWeight: FontWeight.w100,
              color: Colors.grey[750], // 진한 회색
              fontSize: 12.0,
              ),
                ),
                RowItem(
              color: Color.fromARGB(255, 255, 204, 77).withOpacity(1),
              label: 'leisure',
              textStyle: TextStyle(
              fontFamily: 'JAL',
              fontWeight: FontWeight.w100,
              color: Colors.grey[750], // 진한 회색
              fontSize: 12.0,
              ),
                ),
                RowItem(
              color: Color.fromARGB(255, 175, 246, 255).withOpacity(1),
              label: 'traffic',
              textStyle: TextStyle(
              fontFamily: 'JAL',
              fontWeight: FontWeight.w100,
              color: Colors.grey[750], // 진한 회색
              fontSize: 12.0,
              ),
                ),
                RowItem(
              color: Color.fromARGB(255, 219, 133, 196).withOpacity(1),
              label: 'shopping',
              textStyle: TextStyle(
              fontFamily: 'JAL',
              fontWeight: FontWeight.w100,
              color: Colors.grey[750], // 진한 회색
              fontSize: 12.0,
              ),
                ),
                RowItem(
              color: Color.fromARGB(255, 226, 226, 226).withOpacity(1),
              label: 'etc',
              textStyle: TextStyle(
              fontFamily: 'JAL',
              fontWeight: FontWeight.w100,
              color: Colors.grey[750], // 진한 회색
              fontSize: 12.0,
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
              child: Padding(
              padding: EdgeInsets.only(bottom: 40.0), // 원하는 여백 값
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
                },
              ),
              ),
                )
                    ],
                ),
            ),//컨테이너 하나(현재 해당하는 달)), //요 세줄 바꿔야되는데 이 셋은 위에있는 height보다 작아야함
              Container(width: double.infinity, height: 650, color: Color(0xFFF8F6E8),
              child: expenses.isEmpty ? _buildNoExpensesPage() : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 Positioned(
  bottom: 0,
  right: 0,
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
        '$formattedLastMonth                                                                           ',
      style: TextStyle(
        color: const Color.fromARGB(255, 52, 52, 52),
        fontWeight: FontWeight.bold,
        fontSize: 18, // 원하는 크기로 조절
        fontFamily: 'JAL', // 사용할 폰트로 변경
      ),
    ),
  ),
),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                      child: FutureBuilder<List<PieModel>>(
                        future: generatePieChartLastMonthData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            List<PieModel> modelLastMonth = snapshot.data ?? [];

                            return AnimatedBuilder(
                              animation: animationController,
                              builder: (context, child) {
                                if (animationController.value < 0.1) {
                                  return const SizedBox();
                                }
                                return CustomPaint(
                                  size: Size(
                                    MediaQuery.of(context).size.width,
                                    200,
                                  ),
                                  painter: _PieChart(modelLastMonth, animationController),
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
                ),
                Expanded(
                  flex: 1,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Positioned(
                        left: 400.0,
                        top: 8.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RowItem(
                              color: Color.fromARGB(255, 129, 201, 134).withOpacity(1),
                              label: 'food',
                              textStyle: TextStyle(
                                fontFamily: 'JAL',
                                fontWeight: FontWeight.w100,
                                color: Colors.grey[750],
                                fontSize: 12.0,
                              ),
                            ),
                            RowItem(
                              color: Color.fromARGB(255, 255, 204, 77).withOpacity(1),
                              label: 'leisure',
                              textStyle: TextStyle(
                                fontFamily: 'JAL',
                                fontWeight: FontWeight.w100,
                                color: Colors.grey[750],
                                fontSize: 12.0,
                              ),
                            ),
                            RowItem(
                              color: Color.fromARGB(255, 175, 246, 255).withOpacity(1),
                              label: 'traffic',
                              textStyle: TextStyle(
                                fontFamily: 'JAL',
                                fontWeight: FontWeight.w100,
                                color: Colors.grey[750],
                                fontSize: 12.0,
                              ),
                            ),
                            RowItem(
                              color: Color.fromARGB(255, 219, 133, 196).withOpacity(1),
                              label: 'shopping',
                              textStyle: TextStyle(
                                fontFamily: 'JAL',
                                fontWeight: FontWeight.w100,
                                color: Colors.grey[750],
                                fontSize: 12.0,
                              ),
                            ),
                            RowItem(
                              color: Color.fromARGB(255, 226, 226, 226).withOpacity(1),
                              label: 'etc',
                              textStyle: TextStyle(
                                fontFamily: 'JAL',
                                fontWeight: FontWeight.w100,
                                color: Colors.grey[750],
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 40.0),
                    child: FutureBuilder<List<HorizontalDetailsModel>>(
                      future: generateBarChartLastMonthData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          List<HorizontalDetailsModel> barChartDataLastMonth = snapshot.data ?? [];

                          return SimpleBarChart(
                            makeItDouble: true,
                            listOfHorizontalBarData: barChartDataLastMonth,
                            verticalInterval: 50000,
                            horizontalBarPadding: 20,
                          );
                        } else {
                          return CircularProgressIndicator();
 }
            },
          ),
        ),
      )
    ],
  ),
),
               
            ],
          ),
        ),
      ),
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
          child:  BottomNavigationBar(
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
    )
    );
}
    Widget _buildNoExpensesPage() {
  // 지출 데이터가 없을 때 표시되는 페이지
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
  'No expense records,\n\nor they are currently loading!',
  style: TextStyle(
    fontSize: 25.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'JAL',
  ),
  textAlign: TextAlign.center,
),

        SizedBox(height: 16.0),
        Image.asset(
          'assets/Lovepik.png',
          width: 170.0,
          height: 170.0,
        ),
      ],
    ),
  );
}
  } //widget build









class _PieChart extends CustomPainter {
  final List<PieModel> data;
  final Animation<double> animation;

  _PieChart(this.data, this.animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = const Color.fromRGBO(61, 61, 61, 1);

    Paint circlePaint = Paint()..color = Color(0xFFF8F6E8);

    Offset offset = Offset(size.width / 2, size.width / 2);
    double radius = (size.width / 2) * 0.65;

    canvas.drawCircle(offset, radius, circlePaint);
    paint.strokeWidth = 50;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;

    double totalPercentage = 0.0; // 각 파이의 시작 각도를 계산하기 위한 변수

    for (int i = 0; i < data.length; i++) {
      double startAngle = totalPercentage * 2 * math.pi; // 시작 각도 계산
      double endAngle = (totalPercentage + data[i].count / 100) * 2 * math.pi; // 종료 각도 계산
      
      double animatedStartAngle = startAngle * animation.value; // 애니메이션 적용
       
      circlePaint.color = data[i].color;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.width / 2), radius: radius),
        animatedStartAngle - math.pi / 2, // 시작 각도를 -π / 2로 초기화
        (endAngle - startAngle) * animation.value, // 애니메이션 적용
        true,
        circlePaint,
      );

      totalPercentage += data[i].count / 100;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: graph(),
  ));
}     