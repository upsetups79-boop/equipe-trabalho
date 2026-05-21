import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/database_helper.dart';
import '../services/schedule_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Employee? employee;

  const AddEmployeeScreen({super.key, this.employee});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedShift = 'Manhã';
  String _selectedColor = '2196F3';
  String _selectedSchedule = '6x1';
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  final List<String> _shifts = ['Manhã', 'Noite'];
  final List<String> _schedules = ['6x1', '5x2', '4x3', '3x3'];
  final List<String> _colors = [
    '2196F3',
    '4CAF50',
    'FF9800',
    'E91E63',
    '9C27B0',
    '795548',
    '607D8B',
    'F44336',
    '3F51B5',
    '009688',
    'FFC107',
    'FF5722',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.name;
      _selectedShift = widget.employee!.shift;
      _selectedColor = widget.employee!.color;
      _startTime = _parseTime(widget.employee!.startTime);
      _endTime = _parseTime(widget.employee!.endTime);
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      final employee = Employee(
        id: widget.employee?.id,
        name: _nameController.text,
        shift: _selectedShift,
        schedule: _selectedSchedule,
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
        color: _selectedColor,
        isActive: widget.employee?.isActive ?? true,
      );

      if (widget.employee != null) {
        await DatabaseHelper.instance.updateEmployee(employee);
      } else {
        await DatabaseHelper.instance.insertEmployee(employee);
        // Auto-generate schedule for new employee
        await ScheduleService.instance.generateSchedule(DateTime.now(), 3);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.employee != null ? 'Editar Funcionário' : 'Novo Funcionário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Funcionário',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: João Silva',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedShift,
                decoration: const InputDecoration(
                  labelText: 'Turno',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                items: _shifts.map((shift) {
                  return DropdownMenuItem(
                    value: shift,
                    child: Text(shift),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedShift = value!);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSchedule,
                decoration: const InputDecoration(
                  labelText: 'Escala de Trabalho',
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                items: _schedules.map((schedule) {
                  return DropdownMenuItem(
                    value: schedule,
                    child: Text(schedule),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSchedule = value!);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Horário de Entrada'),
                      subtitle: Text(_formatTime(_startTime)),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectStartTime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ListTile(
                      title: const Text('Horário de Saída'),
                      subtitle: Text(_formatTime(_endTime)),
                      trailing: const Icon(Icons.access_time),
                      onTap: _selectEndTime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Cor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(int.parse('FF$color', radix: 16)),
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveEmployee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.employee != null ? 'Salvar' : 'Adicionar e Gerar Escala',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
