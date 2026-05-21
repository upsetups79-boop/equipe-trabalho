import '../models/employee.dart';
import '../models/schedule.dart';
import 'database_helper.dart';

class ScheduleService {
  static final ScheduleService instance = ScheduleService._init();

  ScheduleService._init();

  // Generate 6x1 schedule for all employees
  // 6x1 means: 6 days working, 1 day off
  // The day off rotates among employees in the same shift
  Future<void> generateSchedule(DateTime startDate, int months) async {
    final employees = await DatabaseHelper.instance.getEmployees();
    final activeEmployees = employees.where((e) => e.isActive).toList();

    // Group employees by shift
    final Map<String, List<Employee>> shiftGroups = {};
    for (final employee in activeEmployees) {
      if (!shiftGroups.containsKey(employee.shift)) {
        shiftGroups[employee.shift] = [];
      }
      shiftGroups[employee.shift]!.add(employee);
    }

    // Generate schedule for each shift
    for (final entry in shiftGroups.entries) {
      final shift = entry.key;
      final employeesInShift = entry.value;

      if (employeesInShift.isEmpty) continue;

      // Calculate end date
      final endDate = DateTime(
        startDate.year,
        startDate.month + months,
        startDate.day,
      );

      // Generate schedules for each day
      for (var date = startDate;
          date.isBefore(endDate);
          date = date.add(const Duration(days: 1))) {
        final daysDifference = date.difference(startDate).inDays;

        // Create schedule for each employee in this shift
        for (int i = 0; i < employeesInShift.length; i++) {
          final employee = employeesInShift[i];

          // 6x1 logic: employee has day off when (daysDifference - i) % 7 == 0
          // This means each employee works 6 days then has 1 day off
          // The day off is staggered by the employee index
          final isDayOff = (daysDifference - i) % 7 == 0;

          final schedule = Schedule(
            employeeId: employee.id!,
            date: date,
            type: isDayOff ? 'folga' : 'trabalho',
          );

          // Check if schedule already exists
          final existingSchedules =
              await DatabaseHelper.instance.getSchedulesByDate(date);
          final existingSchedule = existingSchedules
              .where((s) => s.employeeId == employee.id)
              .firstOrNull;

          if (existingSchedule != null) {
            // Update existing schedule
            await DatabaseHelper.instance.updateSchedule(
              schedule.copyWith(id: existingSchedule.id),
            );
          } else {
            // Insert new schedule
            await DatabaseHelper.instance.insertSchedule(schedule);
          }
        }
      }
    }
  }

  // Get employees on leave for a specific date
  Future<List<Employee>> getEmployeesOnLeave(DateTime date) async {
    final schedules = await DatabaseHelper.instance.getSchedulesByDate(date);
    final leaveSchedules = schedules.where((s) => s.type == 'folga').toList();

    final employees = <Employee>[];
    for (final schedule in leaveSchedules) {
      final employee = await DatabaseHelper.instance.getEmployees().then(
            (employees) =>
                employees.where((e) => e.id == schedule.employeeId).firstOrNull,
          );
      if (employee != null) {
        employees.add(employee);
      }
    }

    return employees;
  }

  // Get employees working for a specific date
  Future<List<Employee>> getEmployeesWorking(DateTime date) async {
    final schedules = await DatabaseHelper.instance.getSchedulesByDate(date);
    final workSchedules =
        schedules.where((s) => s.type == 'trabalho').toList();

    final employees = <Employee>[];
    for (final schedule in workSchedules) {
      final employee = await DatabaseHelper.instance.getEmployees().then(
            (employees) =>
                employees.where((e) => e.id == schedule.employeeId).firstOrNull,
          );
      if (employee != null) {
        employees.add(employee);
      }
    }

    return employees;
  }

  // Get next day off for an employee
  Future<DateTime?> getNextDayOff(int employeeId) async {
    final now = DateTime.now();
    final schedules =
        await DatabaseHelper.instance.getSchedulesByEmployee(employeeId);

    for (final schedule in schedules) {
      if (schedule.type == 'folga' && schedule.date.isAfter(now)) {
        return schedule.date;
      }
    }

    return null;
  }

  // Get schedule for an employee for a specific month
  Future<List<Schedule>> getEmployeeMonthSchedule(
      int employeeId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final schedules =
        await DatabaseHelper.instance.getSchedulesByEmployee(employeeId);
    return schedules
        .where((s) =>
            s.date.isAfter(startOfMonth) && s.date.isBefore(endOfMonth))
        .toList();
  }
}
