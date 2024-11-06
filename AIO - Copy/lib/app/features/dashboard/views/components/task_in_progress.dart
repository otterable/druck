// My lib/app/features/dashboard/views/components/task_in_progress.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.

import 'package:flutter/material.dart';
import 'package:daily_task/app/shared_components/card_task.dart';

class TaskInProgress extends StatelessWidget {
  final List<CardTaskData> data;
  final Color textColor;

  const TaskInProgress({required this.data, required this.textColor, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CardTask(
              data: data[index],
              primary: _getSequenceColor(index),
              onPrimary: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Color _getSequenceColor(int index) {
    int val = index % 4;
    switch (val) {
      case 3:
        return Colors.indigo;
      case 2:
        return Colors.grey;
      case 1:
        return Colors.redAccent;
      default:
        return Colors.lightBlue;
    }
  }
}
