import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/schedule_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isGenerating = false;

  Future<void> _generateSchedule() async {
    setState(() => _isGenerating = true);

    try {
      final startDate = DateTime.now();
      await ScheduleService.instance.generateSchedule(startDate, 3);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escala gerada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar escala: $e')),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar dados'),
        content: const Text(
            'Deseja limpar todos os dados? Isso excluirá todos os funcionários e escalas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = await DatabaseHelper.instance.database;
      await db.delete('schedules');
      await db.delete('employees');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados limpos com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildNotificationsButton(),
            const SizedBox(height: 16),
            _buildGenerateButton(),
            const SizedBox(height: 16),
            _buildClearButton(),
            const SizedBox(height: 24),
            _buildAboutCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text('Sobre a Escala',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'O sistema de escala 6×1 funciona da seguinte forma:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Cada funcionário trabalha 6 dias e folga 1 dia'),
            const Text('• As folgas são rotativas entre os funcionários'),
            const Text('• Cada turno tem 3 funcionários'),
            const Text('• Sempre terá 2 funcionários trabalhando por turno'),
            const SizedBox(height: 12),
            const Text(
              'Exemplo para 6 funcionários (3 por turno):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Turno Manhã: Func1, Func2, Func3'),
            const Text('Turno Noite: Func4, Func5, Func6'),
            const SizedBox(height: 8),
            const Text('Dia 1: Func1 e Func4 folgam'),
            const Text('Dia 2: Func2 e Func5 folgam'),
            const Text('Dia 3: Func3 e Func6 folgam'),
            const Text('Dia 4: Func1 e Func4 folgam novamente'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
      },
      icon: const Icon(Icons.notifications),
      label: const Text('Configurar Notificações'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed: _isGenerating ? null : _generateSchedule,
      icon: _isGenerating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.calendar_month),
      label: Text(
          _isGenerating ? 'Gerando...' : 'Gerar Escala (3 meses)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return ElevatedButton.icon(
      onPressed: _clearData,
      icon: const Icon(Icons.delete_forever),
      label: const Text('Limpar Todos os Dados'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.app_settings_alt, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text('Minha Escala',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Versão 1.0.0'),
            const Text('App para gerenciamento de escalas de trabalho'),
            const SizedBox(height: 8),
            const Text(
              'Desenvolvido com Flutter',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
