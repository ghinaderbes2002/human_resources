import 'package:flutter/material.dart';

class EmployeeInfoCard extends StatelessWidget {
  final String name;
  final String? employeeId;

  const EmployeeInfoCard({super.key, required this.name, this.employeeId});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFFE85D4A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE85D4A), // الأساسي
            Color(0xFFEF7A69), // أفتح شوي
            Color(0xFFF6A49A), // أفتح أكثر
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الموظف
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),

          // معلومات الموظف
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              if (employeeId != null)
                Text(
                  "ID: $employeeId",
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
