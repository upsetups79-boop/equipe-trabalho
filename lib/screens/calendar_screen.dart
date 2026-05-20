import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../models/schedule.dart';
import '../services/database_helper.dart';
import '../services/schedule_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Employee> _employeesOnLeave = [];
  List<Employee> _employeesWorking = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData(_selectedDay!);
  }

  Future<void> _loadData(DateTime date) async {
    setState(() => _isLoading = true);

    final employeesOnLeave =
        await ScheduleService.instance.getEmployeesOnLeave(date);
    final employeesWorking =
        await ScheduleService.instance.getEmployeesWorking(date);

    if (mounted) {
      setState(() {
        _employeesOnLeave = employeesOnLeave;
        _employeesWorking = employeesWorking;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'pt_BR',
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadData(selectedDay);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue[400],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue[700],
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.orange[400],
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                return FutureBuilder<List<Employee>>(
                  future: ScheduleService.instance.getEmployeesOnLeave(day),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.orange[400],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${snapshot.data!.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSelectedDateHeader(),
                        const SizedBox(height: 16),
                        if (_employeesOnLeave.isNotEmpty) ...[
                          _buildOnLeaveSection(),
                          const SizedBox(height: 16),
                        ],
                        _buildWorkingSection(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateHeader() {
    final dateFormat = DateFormat('EEEE, d \'de\' MMMM', 'pt_BR');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(_selectedDay!),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _selectedDay!.day == DateTime.now().day &&
                            _selectedDay!.month == DateTime.now().month &&
                            _selectedDay!.year == DateTime.now().year
                        ? 'Hoje'
                        : 'Dia selecionado',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnLeaveSection() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hotel, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'De Folga (${_employeesOnLeave.length})',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _employeesOnLeave.map((employee) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Color(
                      int.parse('FF${employee.color}', radix: 16),
                    ),
                    child: Text(
                      employee.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  label: Text(employee.name),
                  backgroundColor: Colors.orange[100],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Trabalhando (${_employeesWorking.length})',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _employeesWorking.map((employee) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Color(
                      int.parse('FF${employee.color}', radix: 16),
                    ),
                    child: Text(
                      employee.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  label: Text(employee.name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
