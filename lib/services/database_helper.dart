import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/employee.dart';
import '../models/schedule.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('minha_escala.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(path, version: 3, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        shift TEXT NOT NULL,
        schedule TEXT NOT NULL DEFAULT '6x1',
        startTime TEXT NOT NULL DEFAULT '08:00',
        endTime TEXT NOT NULL DEFAULT '17:00',
        color TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId INTEGER NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY (employeeId) REFERENCES employees (id)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE employees ADD COLUMN startTime TEXT NOT NULL DEFAULT "08:00"');
      await db.execute('ALTER TABLE employees ADD COLUMN endTime TEXT NOT NULL DEFAULT "17:00"');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE employees ADD COLUMN schedule TEXT NOT NULL DEFAULT "6x1"');
    }
  }

  // Employee methods
  Future<int> insertEmployee(Employee employee) async {
    final db = await instance.database;
    return await db.insert('employees', employee.toMap());
  }

  Future<List<Employee>> getEmployees() async {
    final db = await instance.database;
    final maps = await db.query('employees', orderBy: 'name ASC');
    return maps.map((map) => Employee.fromMap(map)).toList();
  }

  Future<List<Employee>> getEmployeesByShift(String shift) async {
    final db = await instance.database;
    final maps = await db.query(
      'employees',
      where: 'shift = ?',
      whereArgs: [shift],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Employee.fromMap(map)).toList();
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await instance.database;
    return await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<int> deleteEmployee(int id) async {
    final db = await instance.database;
    await db.delete('schedules', where: 'employeeId = ?', whereArgs: [id]);
    return await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  // Schedule methods
  Future<int> insertSchedule(Schedule schedule) async {
    final db = await instance.database;
    return await db.insert('schedules', schedule.toMap());
  }

  Future<List<Schedule>> getSchedules() async {
    final db = await instance.database;
    final maps = await db.query('schedules', orderBy: 'date ASC');
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesByDate(DateTime date) async {
    final db = await instance.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final maps = await db.query(
      'schedules',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesByEmployee(int employeeId) async {
    final db = await instance.database;
    final maps = await db.query(
      'schedules',
      where: 'employeeId = ?',
      whereArgs: [employeeId],
      orderBy: 'date ASC',
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<List<Schedule>> getSchedulesByDateRange(
      DateTime start, DateTime end) async {
    final db = await instance.database;
    final maps = await db.query(
      'schedules',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );
    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final db = await instance.database;
    return await db.update(
      'schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteSchedule(int id) async {
    final db = await instance.database;
    return await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSchedulesByEmployee(int employeeId) async {
    final db = await instance.database;
    return await db.delete('schedules',
        where: 'employeeId = ?', whereArgs: [employeeId]);
  }
}
