import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginButton extends StatelessWidget {
  final MyController _controller = Get.find<MyController>();

  LoginButton();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _controller.isLoading.value
          ? const CircularProgressIndicator(
              strokeWidth: 1.5,
              backgroundColor: Colors.white,
            )
          : SizedBox(
              height: 45.0,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Change to your desired color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: () {
                  _controller.onLoginPressed(context);
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                  ),
                ),
              ),
            ),
    );
  }
}

class MyController extends GetxController {
  // Your controller logic goes here
  var isLoading = false.obs;

  void onLoginPressed(BuildContext context) {
    // Your login logic goes here
  }
}
