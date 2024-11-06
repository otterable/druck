// My lib/app/features/dashboard/views/components/weekly_task.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.

import 'package:flutter/material.dart';
import 'package:daily_task/app/shared_components/list_task_assigned.dart';

class WeeklyTask extends StatelessWidget {
  final List<ListTaskAssignedData> data;
  final Function(int index, ListTaskAssignedData data) onPressed;
  final Function(int index, ListTaskAssignedData data) onPressedAssign;
  final Function(int index, ListTaskAssignedData data) onPressedMember;
  final Color? textColor;

  const WeeklyTask({
    required this.data,
    required this.onPressed,
    required this.onPressedAssign,
    required this.onPressedMember,
    this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.map((task) {
        return ListTile(
          title: Text(
            task.label,
            style: TextStyle(color: textColor ?? Colors.black),
          ),
          onTap: () => onPressed(data.indexOf(task), task),
        );
      }).toList(),
    );
  }
}
