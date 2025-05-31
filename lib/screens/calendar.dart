import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _events = {};

  late final TextEditingController _eventController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _eventController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final loadedEvents = <DateTime, List<String>>{};

    // 1. 사용자 커스텀 이벤트
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('events')
        .get();

    for (var doc in eventsSnapshot.docs) {
      final data = doc.data();
      final rawDate = data['date'];
      DateTime? date;

      if (rawDate is Timestamp) {
        date = rawDate.toDate();
      } else if (rawDate is String) {
        date = DateTime.tryParse(rawDate);
      }
      if (date == null) continue;

      final day = DateTime.utc(date.year, date.month, date.day);
      final title = data['title'] ?? '기념일';
      loadedEvents[day] = [...?loadedEvents[day], title];
    }

    // 2. 친구 생일
    final friendsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('friends')
        .get();

    for (var doc in friendsSnapshot.docs) {
      final data = doc.data();
      final birthdayStr = data['birthday'];
      final name = data['name'] ?? '이름 없는 친구';

      if (birthdayStr is String) {
        final parsed = DateTime.tryParse(birthdayStr);
        if (parsed != null) {
          final today = DateTime.now();
          final birthday = DateTime.utc(today.year, parsed.month, parsed.day);
          final label = "$name 생일 🎂";
          loadedEvents[birthday] = [...?loadedEvents[birthday], label];
        }
      }
    }

    setState(() {
      _events.clear();
      _events.addAll(loadedEvents);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _eventController.dispose();
    super.dispose();
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _showScheduleBottomSheet(BuildContext context, List<String> schedules) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    '기념일 목록',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            schedules[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddEventPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScaleTransition(
          scale: _animation,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('일정 추가'),
            content: TextField(
              controller: _eventController,
              decoration: const InputDecoration(hintText: '기념일을 입력하세요'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소', style: TextStyle(color: Color.fromARGB(255, 78, 78, 78))),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newEvent = _eventController.text.trim();
                  if (newEvent.isNotEmpty && _selectedDay != null) {
                    final day = DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('events')
                          .add({
                        'title': newEvent,
                        'date': Timestamp.fromDate(day),
                      });
                      _fetchEvents();
                    }
                  }
                  _eventController.clear();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B57C6)),
                child: const Text('추가', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showScheduleBottomSheet(context, _getEventsForDay(selectedDay));
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF2B57C6),
                  shape: BoxShape.circle,
                ),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.grey),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              eventLoader: _getEventsForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(events.length > 3 ? 3 : events.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.lightBlue,
                            ),
                          );
                        }),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventPopup,
        backgroundColor: const Color(0xFF2B57C6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
