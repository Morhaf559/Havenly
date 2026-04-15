import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/features/auth/controllers/otp_controller.dart';
import 'package:my_havenly_application/features/auth/view/widget/code_box.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OtpController otpController = Get.find<OtpController>();
    final String phone = Get.arguments?['phone'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Verification Code'.tr),
        backgroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the code :'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(phone, style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => CodeBox(index: index, controller: otpController),
              ),
            ),
            const SizedBox(height: 40),

            Obx(
              () => otpController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        otpController.otpVerify(Get.arguments?['phone'] ?? "");
                      },
                      child: Text('Submit'.tr, style: TextStyle(fontSize: 18)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
