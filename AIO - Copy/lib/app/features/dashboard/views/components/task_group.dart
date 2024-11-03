// My lib/app/features/dashboard/views/components/task_group.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.

import 'package:flutter/material.dart';
import 'package:daily_task/app/shared_components/list_task_date.dart';

class TaskGroup extends StatelessWidget {
  final List<ListTaskDateData> data;
  final Function(int index, ListTaskDateData data) onPressed;
  final Color? textColor;

  const TaskGroup({
    required this.data,
    required this.onPressed,
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
