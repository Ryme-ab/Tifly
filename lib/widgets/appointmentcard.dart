import 'package:flutter/material.dart';
import 'package:tifli/features/schedules/presentation/screens/appointment_details_screen.dart';

class AppointmentCard extends StatelessWidget {
  final String time;
  final String title;
  final String appointmentId;
  final String childId;
  final VoidCallback onDelete; // 🔴 callback to delete

  const AppointmentCard({
    super.key,
    required this.time,
    required this.title,
    required this.appointmentId,
    required this.childId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(appointmentId),
      direction: DismissDirection.endToStart, // 👈 swipe left only
      background: _buildDeleteBackground(),
      confirmDismiss: (_) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (_) {
        onDelete(); // 🔥 actually delete
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentDetailsScreen(
                appointmentId: appointmentId,
                childId: childId,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xfffff0f5),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.pink.shade200, width: 2),
                  ),
                ),
                child: Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xffb03a57),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      "Details",
                      style: TextStyle(color: Colors.pinkAccent),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.track_changes, color: Color(0xffb03a57)),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔴 Red background when swiping
  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  /// ❓ Confirmation dialog
  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete appointment"),
        content: const Text(
          "Are you sure you want to delete this appointment?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
