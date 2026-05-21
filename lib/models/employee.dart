class Employee {
  final int? id;
  final String name;
  final String shift;
  final String schedule;
  final String startTime;
  final String endTime;
  final String color;
  final bool isActive;

  Employee({
    this.id,
    required this.name,
    required this.shift,
    required this.schedule,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shift': shift,
      'schedule': schedule,
      'startTime': startTime,
      'endTime': endTime,
      'color': color,
      'isActive': isActive ? 1 : 0,
    };
  }

  static Employee fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      shift: map['shift'],
      schedule: map['schedule'] ?? '6x1',
      startTime: map['startTime'] ?? '08:00',
      endTime: map['endTime'] ?? '17:00',
      color: map['color'],
      isActive: map['isActive'] == 1,
    );
  }

  Employee copyWith({
    int? id,
    String? name,
    String? shift,
    String? schedule,
    String? startTime,
    String? endTime,
    String? color,
    bool? isActive,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      shift: shift ?? this.shift,
      schedule: schedule ?? this.schedule,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
    );
  }
}
