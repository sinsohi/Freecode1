import 'package:flutter/material.dart';
//import 'package:charts_flutter_new/flutter.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:math' as math;



class graph extends StatelessWidget {
  const graph({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}



// // 여기부터 파이차트. 잘 나옴
// class PieModel {
//   final int count;
//   final Color color;

//   PieModel({
//     required this.count,
//     required this.color,
//   });
// }

// class graph extends StatefulWidget {
//   const graph({Key? key}) : super(key: key);

//   @override
//   State<graph> createState() => _graphState();
// }
// Example of a Spark Bar by hiding both axis, reducing the chart margins.
// class SparkBar extends StatelessWidget {
//   final List<charts.Series> seriesList;
//   final bool animate;

//   SparkBar(this.seriesList, {this.animate});

//   factory SparkBar.withSampleData() {
//     return new SparkBar(
//       _createSampleData(),
//       // Disable animations for image tests.
//       animate: false,
//     );
//   }
// class _graphState extends State<graph> {
//   @override
//   Widget build(BuildContext context) {
//     List<PieModel> model = [
//       PieModel(count: 30, color: const Color.fromARGB(255, 176, 91, 85).withOpacity(1)),
//       PieModel(count: 5, color: const Color.fromARGB(255, 81, 134, 178).withOpacity(1)),
//       PieModel(count: 3, color: Colors.grey.withOpacity(1)),
//       PieModel(count: 10, color: const Color.fromARGB(255, 185, 163, 95).withOpacity(1)),
//       PieModel(count: 2, color: Color.fromARGB(255, 124, 205, 127).withOpacity(1)),
//       PieModel(count: 30, color: Colors.cyan.withOpacity(1)),
//       PieModel(count: 20, color: const Color.fromARGB(255, 156, 89, 168).withOpacity(1)),
//     ];

//   return Scaffold(
//   appBar: AppBar(title: Text('Graph')),
//   body: Column(
//     children: [
//       Expanded(
//         child: Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.width,
//           child: CustomPaint(
//             size: Size(
//               MediaQuery.of(context).size.width,
//               MediaQuery.of(context).size.width,
//             ),
//             painter: _PieChart(model),
//           ),
//         ),
//       ),
//       // 여기에 다른 위젯 추가 가능
//       new charts.BarChart(
//         seriesList,
//         animate: animate,

//         // Assign a custom style for the measure axis.
//         primaryMeasureAxis:
//             new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),

//         // This is an OrdinalAxisSpec to match up with BarChart's default
//         // ordinal domain axis (use NumericAxisSpec or DateTimeAxisSpec for
//         // other charts).
//         domainAxis: new charts.OrdinalAxisSpec(
//           // Make sure that we draw the domain axis line.
//           showAxisLine: true,
//           // But don't draw anything else.
//           renderSpec: new charts.NoneRenderSpec(),
//         ),

//         // With a spark chart we likely don't want large chart margins.
//         // 1px is the smallest we can make each margin.
//         layoutConfig: new charts.LayoutConfig(
//           leftMarginSpec: new charts.MarginSpec.fixedPixel(0),
//           topMarginSpec: new charts.MarginSpec.fixedPixel(0),
//           rightMarginSpec: new charts.MarginSpec.fixedPixel(0),
//           bottomMarginSpec: new charts.MarginSpec.fixedPixel(0),
//         ),
//       ),
//     ],
//   ),
// );


// /// Sample ordinal data type.
// class OrdinalSales {
//   final String year;
//   final int sales;

//   OrdinalSales(this.year, this.sales);
// }
//         ],
//       ),
//     );
//   }
// }

// class _PieChart extends CustomPainter {
//   final List<PieModel> data;

//   _PieChart(this.data);

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint circlePaint = Paint()..color = Colors.white;

//     Offset offset = Offset(size.width / 2, size.width / 2);
//     double radius = (size.width / 2) * 0.8;
//     canvas.drawCircle(offset, radius, circlePaint);

//     double _startPoint = 0.0;
//     for (int i = 0; i < data.length; i++) {
//       double _startAngle = 2 * math.pi * (data[i].count / 100);
//       double _nextAngle = 2 * math.pi * (data[i].count / 100);
//       circlePaint.color = data[i].color;

//       canvas.drawArc(
//         Rect.fromCircle(
//           center: Offset(size.width / 2, size.width / 2),
//           radius: radius,
//         ),
//         -math.pi / 2 + _startPoint,
//         _nextAngle,
//         true,
//         circlePaint,
//       );
//       _startPoint = _startPoint + _startAngle;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// void main() {
//   runApp(MaterialApp(
//     home: graph(),
//   ));
// }