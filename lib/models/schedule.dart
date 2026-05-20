class Schedule {
  final int? id;
  final int employeeId;
  final DateTime date;
  final String type; // trabalho, folga, extra, ferias

  Schedule({
    this.id,
    required this.employeeId,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  static Schedule fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      employeeId: map['employeeId'],
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }

  Schedule copyWith({
    int? id,
    int? employeeId,
    DateTime? date,
    String? type,
  }) {
    return Schedule(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }
}
