import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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

class _calendarPageState extends State<calendarPage> {
  DateTime today = DateTime.now();
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: content(),
    );
  }

  Widget content() {
    return Column(
      children: [
        Container(
          child: TableCalendar(
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronVisible: false,
              rightChevronVisible: false,
              titleTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xff37736c),
                fontSize: 16,
              ),
            ),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            focusedDay: today,
            firstDay: DateTime.utc(2021, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
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
                color: const Color(0xff37736c),
                shape: BoxShape.circle,
              ),
            ),
          ),
        )
      ],
    );
  }
}
