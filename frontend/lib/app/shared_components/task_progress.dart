
// My lib/app/shared_components/task_progress.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TaskProgressData {
  final int totalTask;
  final int totalCompleted;

  const TaskProgressData({
    required this.totalTask,
    required this.totalCompleted,
  });
}

class TaskProgress extends StatelessWidget {
  final TaskProgressData data;
  final Color? textColor;

  const TaskProgress({
    required this.data,
    this.textColor = Colors.black,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "${data.totalCompleted} of ${data.totalTask} completed",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: LinearPercentIndicator(
            percent: data.totalCompleted / data.totalTask,
            progressColor: Colors.blueGrey,
            backgroundColor: Colors.blueGrey[200],
          ),
        ),
      ],
    );
  }
}
