import 'package:flutter/material.dart';
//import 'package:fl_chart/fl_chart.dart';
//import 'package:syncfusion_flutter_charts/charts.dart';
//import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:unique_simple_bar_chart/data_models.dart';
import 'package:unique_simple_bar_chart/horizontal_bar.dart';
import 'package:unique_simple_bar_chart/horizontal_line.dart';
import 'package:unique_simple_bar_chart/simple_bar_chart.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:math' as math;

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
  @override
  Widget build(BuildContext context) {
    List<PieModel> model = [
      PieModel(count: 30, color: Color.fromARGB(255, 255, 17, 0).withOpacity(1)),
      PieModel(count: 5, color: Color.fromARGB(255, 30, 154, 255).withOpacity(1)),
      PieModel(count: 3, color: const Color.fromARGB(255, 214, 214, 214).withOpacity(1)),
      PieModel(count: 10, color: Color.fromARGB(255, 255, 233, 65).withOpacity(1)),
      PieModel(count: 2, color: Color.fromARGB(255, 124, 205, 127).withOpacity(1)),
      PieModel(count: 30, color: Colors.cyan.withOpacity(1)),
      PieModel(count: 20, color: Color.fromARGB(255, 255, 143, 238).withOpacity(1)),
    ];
    
    return Scaffold(
      appBar: AppBar(title: Text('graph')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, //중앙정렬
        children: [
          Container( //원래 Sizedbox였는데 좀 바꿈
            width: MediaQuery.of(context).size.width,
            height: 10,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.width),
              painter: _PieChart(model),
            ),
          ),
          //여기에 막대그래프 추가
          Container(
            //막대그래프 코드
            height: 100,
        width: MediaQuery.of(context).size.width,
        child: SimpleBarChart(
          makeItDouble: true,
          listOfHorizontalBarData: [
            HorizontalDetailsModel(
              name: 'Mon',
              color: const Color(0xFFEB7735),
              size: 73,
              sizeTwo: 40,
              colorTwo: Colors.blue,
            ),
            HorizontalDetailsModel(
              name: 'Tues',
              color: const Color(0xFFEB7735),
              size: 92,
              sizeTwo: 85,
              colorTwo: Colors.blue,
            ),
            HorizontalDetailsModel(
              name: 'Wed',
              color: const Color(0xFFFBBC05),
              size: 120,
              sizeTwo: 100,
              colorTwo: Colors.blue,
            ),
            HorizontalDetailsModel(
              name: 'Thurs',
              color: const Color(0xFFFBBC05),
              size: 86,
              sizeTwo: 220,
              colorTwo: Colors.blue,
            ),
            HorizontalDetailsModel(
              name: 'Fri',
              color: const Color(0xFFFBBC05),
              size: 64,
              sizeTwo: 170,
              colorTwo: Colors.blue,
            ),
            HorizontalDetailsModel(
              name: 'Sat',
              color: const Color(0xFFFBBC05),
              size: 155,
              sizeTwo: 120,
              colorTwo: Colors.blue,
            ),
            HorizontalDetailsModel(
              name: 'Sun',
              color: const Color(0xFFFBBC05),
              size: 200,
              sizeTwo: 96,
              colorTwo: Colors.blue,
            ),
          ],
          verticalInterval: 100,
          horizontalBarPadding: 20,
          )
      )],
      ),
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
    double radius = (size.width / 2) * 0.8;
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

void main() {
  runApp(MaterialApp(
    home: graph(),
  ));
}   