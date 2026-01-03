import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyOverviewPage extends StatefulWidget {
  const MonthlyOverviewPage({super.key});

  @override
  State<MonthlyOverviewPage> createState() => _MonthlyOverviewPageState();
}

class _MonthlyOverviewPageState extends State<MonthlyOverviewPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<DateTime, Map<String, String>> _events = {};

  // ================= DATE HELPERS =================
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dateId(DateTime date) {
    final d = _normalizeDate(date);
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  Map<String, String> get _selectedEvents =>
      _events[_normalizeDate(_selectedDay)] ?? {};

  // ================= LOAD EVENTS =================
  Future<void> _loadEventsForMonth(DateTime focusedDay) async {
    final snapshot = await _firestore.collection('calendar_events').get();

    final Map<DateTime, Map<String, String>> loadedEvents = {};

    for (var doc in snapshot.docs) {
      final parts = doc.id.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      loadedEvents[date] = Map<String, String>.from(doc['events']);
    }

    setState(() {
      _events = loadedEvents;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEventsForMonth(_focusedDay);
  }

  // ================= ADD EVENT =================
  void _addEventDialog() {
    String selectedTime = "10:00";
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedTime,
              decoration: const InputDecoration(labelText: "Time"),
              items: const [
                "10:00",
                "11:00",
                "12:00",
                "13:00",
                "14:00",
                "15:00",
                "16:00",
              ]
                  .map(
                    (time) => DropdownMenuItem(
                  value: time,
                  child: Text(time),
                ),
              )
                  .toList(),
              onChanged: (value) => selectedTime = value!,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Note"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final dateKey = _normalizeDate(_selectedDay);
              final docId = _dateId(_selectedDay);

              setState(() {
                _events.putIfAbsent(dateKey, () => {});
                _events[dateKey]![selectedTime] = noteController.text;
              });

              await _firestore
                  .collection('calendar_events')
                  .doc(docId)
                  .set({
                'events': _events[dateKey],
              }, SetOptions(merge: true));

              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ================= EDIT EVENT =================
  void _editEvent(String time) {
    final controller = TextEditingController(text: _selectedEvents[time]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Event ($time)"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Note"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final dateKey = _normalizeDate(_selectedDay);
              final docId = _dateId(_selectedDay);

              setState(() {
                _events.putIfAbsent(dateKey, () => {});
                _events[dateKey]![time] = controller.text;
              });

              await _firestore
                  .collection('calendar_events')
                  .doc(docId)
                  .set({
                'events': _events[dateKey],
              }, SetOptions(merge: true));

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ================= DELETE EVENT =================
  void _deleteEvent(String time) async {
    final dateKey = _normalizeDate(_selectedDay);
    final docId = _dateId(_selectedDay);

    setState(() {
      _events[dateKey]?.remove(time);
    });

    if (_events[dateKey]?.isEmpty ?? false) {
      await _firestore.collection('calendar_events').doc(docId).delete();
    } else {
      await _firestore
          .collection('calendar_events')
          .doc(docId)
          .set({
        'events': _events[dateKey],
      }, SetOptions(merge: true));
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        title: const Text("Monthly Overview"),
        backgroundColor: const Color(0xFFF2F7E2),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC280A2),
        child: const Icon(Icons.add),
        onPressed: _addEventDialog,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFC280A2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              eventLoader: (day) =>
              _events[_normalizeDate(day)]?.keys.toList() ?? [],
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadEventsForMonth(focusedDay);
              },
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
            ),
          ),
          Expanded(
            child: _selectedEvents.isEmpty
                ? const Center(child: Text("No events"))
                : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _selectedEvents.keys.map((time) {
                return InkWell(
                  onTap: () => _editEvent(time),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            time,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey[300],
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        Expanded(
                          child: Text(
                            _selectedEvents[time] ?? "",
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit,
                              size: 18, color: Colors.grey),
                          onPressed: () => _editEvent(time),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              size: 18, color: Colors.red),
                          onPressed: () => _deleteEvent(time),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}