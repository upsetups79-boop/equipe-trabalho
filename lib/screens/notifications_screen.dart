import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _dayOffReminders = true;
  bool _scheduleChanges = true;
  bool _paymentReminders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Lembretes de Folga',
              icon: Icons.hotel,
              child: SwitchListTile(
                title: const Text('Receber lembretes de folga'),
                subtitle: const Text('Notificação 1 dia antes da folga'),
                value: _dayOffReminders,
                onChanged: (value) {
                  setState(() => _dayOffReminders = value);
                },
                activeColor: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Alterações na Escala',
              icon: Icons.calendar_month,
              child: SwitchListTile(
                title: const Text('Notificar alterações na escala'),
                subtitle: const Text('Avisar quando a escala for alterada'),
                value: _scheduleChanges,
                onChanged: (value) {
                  setState(() => _scheduleChanges = value);
                },
                activeColor: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Lembretes de Pagamento',
              icon: Icons.payment,
              child: SwitchListTile(
                title: const Text('Receber lembretes de pagamento'),
                subtitle: const Text('Notificar sobre dias de pagamento'),
                value: _paymentReminders,
                onChanged: (value) {
                  setState(() => _paymentReminders = value);
                },
                activeColor: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Sobre as Notificações',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'As notificações são enviadas via Firebase Cloud Messaging. '
              'Você precisa permitir as notificações no dispositivo para receber os avisos.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para configurar o Firebase, siga as instruções no README do projeto.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
