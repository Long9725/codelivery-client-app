import 'package:codelivery/app/ui/sign/components/rounded_password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'package:get/get.dart';

import 'package:lottie/lottie.dart';

import 'package:codelivery/app/constant/constant.dart';

import 'package:codelivery/app/controller/sign.dart';

import 'package:codelivery/app/ui/sign/components/rounded_register_button.dart';
import 'package:codelivery/app/ui/sign/components/rounded_input_field.dart';

import 'package:codelivery/app/ui/getting_started/components/row_text_button_with_description.dart';

class SignBody extends GetView<SignController> {
  SignBody({Key? key}) : super(key: key);

  String name = "";
  String nickname = "";

  void openDialog(String title, String content, List<Widget> actions) {
    Get.dialog(foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS
        ? CupertinoAlertDialog(
            title: Text(title), content: Text(content), actions: actions)
        : AlertDialog(
            title: Text(title), content: Text(content), actions: actions));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final heightInputField = 60;
    final heightButton = 64;
    final heightLottie = size.height - (heightInputField * 4 + heightButton);

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: SingleChildScrollView(
                    // scroll disable
                    // physics: const NeverScrollableScrollPhysics(),
                    child: Center(
                        child: Obx(() => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // SizedBox(height: paddingFromTop),
                                controller.isSign
                                    ? Lottie.asset(
                                        "assets/lotties/register.json",
                                        height: size.width / 2)
                                    : Lottie.asset("assets/lotties/login.json",
                                        height: size.width / 2),
                                RoundedInputField(
                                    maxLength: 20,
                                    hintText: "???????????? ???????????????",
                                    onChanged: (value) =>
                                        controller.sign.userId = value,
                                    onSubmitted: (value) =>
                                        controller.sign.userId = value),
                                controller.isSign
                                    ? RoundedInputField(
                                        maxLength: 20,
                                        hintText: "???????????? ???????????????",
                                        onChanged: (value) =>
                                            controller.sign.nickname = value,
                                        onSubmitted: (value) =>
                                            controller.sign.nickname = value)
                                    : Container(),
                                RoundedPasswordField(
                                    onChanged: (value) =>
                                        controller.sign.password = value,
                                    onSubmitted: (value) =>
                                        controller.sign.password = value),

                                controller.isSign
                                    ? RoundedInputField(
                                        icon: Icons.home_rounded,
                                        maxLength: 50,
                                        hintText: "????????? ???????????????",
                                        onChanged: (value) =>
                                            controller.sign.address = value,
                                        onSubmitted: (value) =>
                                            controller.sign.address = value)
                                    : Container(),
                                RoundedRegisterButton(
                                  onPressed: () async {
                                    if (controller.isSign == true) {
                                      bool isAllInfoEmpty = (controller
                                                      .sign.userId !=
                                                  "" &&
                                              controller.sign.password != "" &&
                                              controller.sign.nickname != "" &&
                                              controller.sign.address != "")
                                          ? false
                                          : true;
                                      if (!isAllInfoEmpty) {
                                        await controller.register();
                                        if (controller.isRegister) {
                                          controller.isSign =
                                              !controller.isSign;
                                        } else {
                                          openDialog(
                                            '????????? ???????????????!',
                                            '??????????????? ??? ??? ????????????.',
                                            [
                                              TextButton(
                                                child: const Text('??????'),
                                                onPressed: () => Get.back(),
                                              )
                                            ],
                                          );
                                          return;
                                        }
                                      } else {
                                        openDialog(
                                          '??? ?????? ?????????',
                                          '????????? ?????? ????????? ??????????????????!',
                                          [
                                            TextButton(
                                              child: const Text('??????'),
                                              onPressed: () => Get.back(),
                                            )
                                          ],
                                        );
                                        return;
                                      }
                                    } else {
                                      if (controller.sign.userId != "" &&
                                          controller.sign.password != "") {
                                        await controller.login();
                                        if (controller.isLogin) {
                                          Get.offAllNamed('/home');
                                        } else {
                                          openDialog(
                                            '????????? ???????????????!',
                                            '???????????? ??? ??? ????????????.',
                                            [
                                              TextButton(
                                                child: const Text('??????'),
                                                onPressed: () => Get.back(),
                                              )
                                            ],
                                          );
                                          return;
                                        }
                                      } else {
                                        openDialog(
                                          '??? ?????? ?????????',
                                          '????????? ?????? ????????? ??????????????????!',
                                          [
                                            TextButton(
                                              child: const Text('??????'),
                                              onPressed: () => Get.back(),
                                            )
                                          ],
                                        );
                                        return;
                                      }
                                    }
                                  },
                                  text: controller.isSign ? "????????????" : "?????????",
                                ),
                                RowTextButtonWithDescription(
                                    description: !controller.isSign
                                        ? "????????? ????????????????"
                                        : "?????? ????????? ????????????????",
                                    text: !controller.isSign ? "????????????" : "?????????",
                                    onPressed: () =>
                                        controller.refreshSignData())
                              ],
                            )))))));
  }
}
