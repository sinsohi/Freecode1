import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

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
      PieModel(count: 20, color: const Color.fromARGB(255, 156, 89, 168).withOpacity(1)),
    ];
    
    return Scaffold(
      appBar: AppBar(title: Text('graph')),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.width),
              painter: _PieChart(model),
            ),
          ),
        ],
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