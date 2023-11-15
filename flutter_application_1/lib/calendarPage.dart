import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class calendarPage extends StatelessWidget {
  const calendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: TableCalendar(
        firstDay: DateTime.utc(2021, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: DateTime.now(),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: calendarPage(),
  ));
}
