import 'package:flutter/material.dart';

import 'package:codelivery/app/constant/constant.dart';
import 'package:codelivery/app/ui/sign/components/text_field_container.dart';

class RoundedInputField extends StatelessWidget {
  const RoundedInputField(
      {Key? key,
      required this.maxLength,
      required this.hintText,
      this.icon = Icons.person,
      required this.onChanged,
      required this.onSubmitted})
      : super(key: key);

  final int maxLength;
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
        child: TextField(
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLength: maxLength,
      decoration: InputDecoration(
          icon: Icon(icon, color: Colors.black),
          counterText: '',
          hintText: hintText,
          border: InputBorder.none),
    ));
  }
}
