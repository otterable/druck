
// My lib/app/views/components/weekly_task.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.
part of dashboard;

class _WeeklyTask extends StatelessWidget {
  final List<ListTaskAssignedData> data;
  final Function(int index, ListTaskAssignedData data) onPressed;
  final Function(int index, ListTaskAssignedData data) onPressedAssign;
  final Function(int index, ListTaskAssignedData data) onPressedMember;
  final Color? textColor;

  const _WeeklyTask({
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
          // remaining fields and methods as needed
        );
      }).toList(),
    );
  }
}
