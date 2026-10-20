import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final String status;

  Color _color() {
    final s = status.toLowerCase();
    if (s.contains('cancel') || s.contains('reject') || s.contains('fail')) {
      return Colors.red;
    }
    if (s.contains('deliver') && !s.contains('out')) return Colors.green;
    if (s.contains('out for')) return Colors.indigo;
    if (s.contains('ready')) return Colors.purple;
    if (s.contains('prepar')) return Colors.orange;
    if (s.contains('confirm')) return Colors.teal;
    if (s.contains('placed')) return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Unknown' : status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
