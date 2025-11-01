// lib/widgets/status_chip.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/issue.dart';

class StatusChip extends StatelessWidget {
  final IssueStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case IssueStatus.resolved:
        color = Colors.green;
        text = 'resolved'.tr;
        icon = Icons.check_circle;
        break;

      case IssueStatus.inProgress:
        color = Colors.blue;
        text = 'inProgress'.tr;
        icon = Icons.hourglass_bottom;
        break;

      case IssueStatus.approved:
        color = Colors.orange;
        text = 'approved'.tr;
        icon = Icons.thumb_up;
        break;

      case IssueStatus.rejected: // <-- NEW CASE ADDED
        color = Colors.red;
        text = 'rejected'.tr; // Ensure you have this translation key
        icon = Icons.cancel;
        break;

      case IssueStatus.pending: // Handle pending explicitly instead of relying on default
      default:
        color = Colors.grey;
        text = 'pending'.tr;
        icon = Icons.pending;
        break;
    }

    return Chip(
        avatar: Icon(icon, color: Colors.white, size: 16),
        label: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact
    );
  }
}