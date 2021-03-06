import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:codelivery/app/constant/constant.dart';
import 'package:codelivery/app/controller/sign.dart';

class RoundedRegisterButton extends GetView<SignController> {
  const RoundedRegisterButton(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.textColor = Colors.white})
      : super(key: key);

  final String text;
  final Function() onPressed;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isAllInfoEmpty = (controller.isSign &&
                controller.sign.userId != "" &&
                controller.sign.password != "" &&
                controller.sign.nickname != "" &&
                controller.sign.address != "") ||
            (!controller.isSign &&
                controller.sign.userId != "" &&
                controller.sign.password != "")
        ? false
        : true;
    // total height = margin 20 + padding 20 + text 24
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: size.width * 0.8,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(29),
            child: ElevatedButton(
                onPressed: onPressed,
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 40)),
                    backgroundColor:
                        // controller.user.nickname.length < 2
                        //     ? MaterialStateProperty.all(kDisableColor)
                        //     :
                        MaterialStateProperty.all(
                            isAllInfoEmpty ? kSystemGray : kPrimaryColor),
                    foregroundColor:
                        // controller.user.nickname.length < 2
                        //     ? MaterialStateProperty.all(kDisableTextColor)
                        //     :
                        MaterialStateProperty.all(
                            isAllInfoEmpty ? kSystemGray : kPrimaryColor)),
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ))));
  }
}
