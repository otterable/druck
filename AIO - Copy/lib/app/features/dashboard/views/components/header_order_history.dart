
// My lib/app/views/components/header_order_history.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.
part of dashboard;

class _HeaderOrderHistory extends StatelessWidget {
  final Color? textColor;

  const _HeaderOrderHistory({this.textColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeaderText("Order History", color: textColor),
        // Additional widgets or spacing as needed
      ],
    );
  }
}
