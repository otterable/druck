
// My lib/app/shared_components/header_text.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.
import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  final String data;
  final Color? color;

  const HeaderText(this.data, {Key? key, this.color = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
  }
}
