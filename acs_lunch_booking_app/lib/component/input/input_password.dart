import 'package:flutter/material.dart';
import '../../appconstant/AppColors.dart';
import 'package:get/get.dart';

class MyController extends GetxController {
  // Use an RxBool to manage the password visibility state
  var passwordVisible = false.obs;

  // Function to toggle the password visibility
  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }
}

class CustomTextDecoration {
  final MyController _controller = Get.put(MyController());

  InputDecoration getDecoration(String text, IconData icon, BuildContext context,
      {bool secure = false}) {
    return InputDecoration(
      labelStyle: const TextStyle(color: Colors.grey),
      labelText: text,
      prefixIcon: Icon(icon, color: AppColors.themeColor),
      suffixIcon: secure == true
          ? IconButton(
              icon: Obx(() => Icon(
                    _controller.passwordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    semanticLabel: _controller.passwordVisible.value
                        ? 'hide password'
                        : 'show password',
                    color: AppColors.greyColorTemp,
                  )),
              onPressed: () {
                // Call the togglePasswordVisibility method from the controller
                _controller.togglePasswordVisibility();
              },
            )
          : null,
      enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.themeColor)),
      focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.themeColor)),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
    );
  }
}
