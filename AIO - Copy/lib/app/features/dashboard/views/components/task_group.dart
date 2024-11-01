
// My lib/app/views/components/task_group.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.
part of dashboard;

class _TaskGroup extends StatelessWidget {
  final String title;
  final List<ListTaskDateData> data;
  final Function(int index, ListTaskDateData data) onPressed;
  final Color? textColor;

  const _TaskGroup({
    required this.title,
    required this.data,
    required this.onPressed,
    this.textColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: textColor ?? Colors.black),
        ),
        // Additional task group data rendering here
      ],
    );
  }
}
