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
    DateTime.utc(2023, 11, 08): [
      Event('식비'),
      Event('교통'),
      Event('쇼핑'),
      Event('여가비'),
      Event('기타'),
    ],
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
    return ListView(
      children: [
        Container(
          child: TableCalendar(
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: const Color(0xff82a282),
                fontWeight: FontWeight.bold,
              ), // 주중의 스타일 설정
              weekendStyle: TextStyle(
                color: const Color(0xff37736c),
                fontWeight: FontWeight.bold,
              ), // 주말의 스타일 설정
            ),
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
                color: const Color(0xff82a282),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: const Color(0xff82a282),
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, dynamic event) {
                if (event.isNotEmpty) {
                  return Container(
                    width: 35,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  );
                } else {
                  return Container(); // event가 비어있을 때는 빈 컨테이너 반환
                }
              },
            ),
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
          _buildEventList('수입', eventsForSelectedDay),
          SizedBox(height: 20),
          _buildEventList('지출', eventsForSelectedDay),
        ],
      );
    } else {
      return Container(); // 이벤트가 없는 경우 빈 컨테이너 반환
    }
  }

  Widget _buildEventList(String title, List<Event> events) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff37736c),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.all(16.0),
      width: 480,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: const Color(0xfff8f6e8),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 150.0,
            decoration: BoxDecoration(
              color: const Color(0xff82a282),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        events[index].name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xfff8f6e8),
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
