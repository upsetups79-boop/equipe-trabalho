class Employee {
  final int? id;
  final String name;
  final String shift;
  final String color;
  final bool isActive;

  Employee({
    this.id,
    required this.name,
    required this.shift,
    required this.color,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shift': shift,
      'color': color,
      'isActive': isActive ? 1 : 0,
    };
  }

  static Employee fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      shift: map['shift'],
      color: map['color'],
      isActive: map['isActive'] == 1,
    );
  }

  Employee copyWith({
    int? id,
    String? name,
    String? shift,
    String? color,
    bool? isActive,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      shift: shift ?? this.shift,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
    );
  }
}
