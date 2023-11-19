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

class Event {
  final String name;

  Event(this.name);
}

class _calendarPageState extends State<calendarPage> {
  DateTime today = DateTime.now();
  Map<DateTime, List<Event>> events = {
    DateTime.utc(2023, 11, 20): [Event('쇼핑')],
    DateTime.utc(2023, 11, 25): [Event('교통')],
  };
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
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
                color: const Color(0xff37736c),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: const Color(0xff82a282),
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: _getEventsForDay,
          ),
        ),
        SizedBox(height: 20),
        _buildEventBanner(),
      ],
    );
  }

  Widget _buildEventBanner() {
    List<Event> eventsForSelectedDay = _getEventsForDay(today);

    if (eventsForSelectedDay.isNotEmpty) {
      return Column(
        children: [
          Container(
            color: const Color(0xff37736c),
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            child: Text(
              'Selected Day Events',
              style: TextStyle(
                fontSize: 18,
                color: const Color(0xfff8f6e8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            color: const Color(0xff82a282),
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: eventsForSelectedDay
                  .map((event) => Text(event.name))
                  .toList(),
            ),
          ),
        ],
      );
    } else {
      return Container(); // 이벤트가 없는 경우 빈 컨테이너 반환
    }
  }
}
