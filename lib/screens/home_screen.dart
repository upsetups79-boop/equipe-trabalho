import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../models/schedule.dart';
import '../services/database_helper.dart';
import '../services/schedule_service.dart';
import 'employees_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Employee> _employeesOnLeave = [];
  List<Employee> _employeesWorking = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final employeesOnLeave =
        await ScheduleService.instance.getEmployeesOnLeave(_selectedDate);
    final employeesWorking =
        await ScheduleService.instance.getEmployeesWorking(_selectedDate);

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
        title: const Text('Minha Escala'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(),
                  const SizedBox(height: 24),
                  _buildTodaySection(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildNextDaysOff(),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Funcionários'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Calendário'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Configurações'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EmployeesScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildDateHeader() {
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
                    dateFormat.format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Hoje',
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

  Widget _buildTodaySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Equipe de Hoje',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildShiftSection('Turno Manhã', _employeesWorking
                .where((e) => e.shift == 'Manhã')
                .toList()),
            const SizedBox(height: 12),
            _buildShiftSection('Turno Noite', _employeesWorking
                .where((e) => e.shift == 'Noite')
                .toList()),
            if (_employeesOnLeave.isNotEmpty) ...[
              const Divider(height: 24),
              _buildOnLeaveSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShiftSection(String title, List<Employee> employees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (employees.isEmpty)
          Text(
            'Nenhum funcionário escalado',
            style: TextStyle(color: Colors.grey[500]),
          )
        else
          Column(
            children: employees.map((employee) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(
                      int.parse('FF${employee.color}', radix: 16),
                    ),
                    child: Text(
                      employee.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    employee.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${employee.startTime} - ${employee.endTime}'),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildOnLeaveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.hotel, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Text(
              'Folga Hoje',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
              backgroundColor: Colors.orange[50],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.people, color: Colors.blue[700], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '${_employeesWorking.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const Text('Trabalhando'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.hotel, color: Colors.orange[700], size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '${_employeesOnLeave.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  const Text('De Folga'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextDaysOff() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Próximas Folgas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Employee>>(
              future: DatabaseHelper.instance.getEmployees(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final employees = snapshot.data!;
                return Column(
                  children: employees.map((employee) {
                    return FutureBuilder<DateTime?>(
                      future: ScheduleService.instance
                          .getNextDayOff(employee.id!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final nextDayOff = snapshot.data!;
                        final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
                        final daysUntil =
                            nextDayOff.difference(DateTime.now()).inDays;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(
                              int.parse('FF${employee.color}', radix: 16),
                            ),
                            child: Text(
                              employee.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(employee.name),
                          subtitle: Text(
                            'Folga em ${dateFormat.format(nextDayOff)}',
                          ),
                          trailing: Text(
                            daysUntil == 0
                                ? 'Hoje'
                                : daysUntil == 1
                                    ? 'Amanhã'
                                    : 'Em $daysUntil dias',
                            style: TextStyle(
                              color: daysUntil <= 1
                                  ? Colors.orange[700]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
