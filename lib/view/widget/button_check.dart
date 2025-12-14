import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havenly/controller/button_check_controller.dart';

class ButtonCheck extends StatelessWidget {
  ButtonCheck({this.iconOff, this.iconOn, this.text});
  String? text;
  Icon? iconOn;
  Icon? iconOff;
  @override
  Widget build(BuildContext context) {
    return GetX<ButtonCheckController>(
      init: ButtonCheckController(),
      builder: (controller) {
        return Row(
          children: [
            IconButton(
              onPressed: () {
                controller.toggle();
              },
              icon: controller.isCheck.value ? iconOn! : iconOff!,
              color: Colors.blue,
              iconSize: 14,
            ),
            Text('${text}', style: TextStyle(fontSize: 10)),
          ],
        );
      },
    );
  }
}
