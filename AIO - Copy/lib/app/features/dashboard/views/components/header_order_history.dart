// My lib/app/features/dashboard/views/components/header_order_history.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.

import 'package:flutter/material.dart';

class HeaderOrderHistory extends StatelessWidget {
  final Color? textColor;

  const HeaderOrderHistory({this.textColor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Order History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }
}
