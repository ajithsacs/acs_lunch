import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../appconstant/AppColors.dart';
import '../../appconstant/strings.dart';
import '../../appconstant/style.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final usernameNode = FocusNode();
  final passwordNode = FocusNode();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final loginData = {}.obs;
  final errorMessage = "".obs;
  final isAutoValidateMode = false.obs;
  final isLoading = false.obs;

  // Use RxBool to manage password visibility
  final passwordVisible = false.obs;

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  void onLoginPressed(BuildContext context) {
    // Your login logic goes here
  }

  @override
  void dispose() {
    usernameNode.dispose();
    passwordNode.dispose();
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class LoginScreen extends StatelessWidget {
  final LoginController _controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Form(
          key: _controller.formKey,
          child: Column(
            children: <Widget>[
              customSizedBox(height: 100.0),
              Container(
                height: 100.0,
                child: Image.asset("assets/loginscreenlogo.png"),
              ),
              customSizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _controller.userNameController,
                      enabled: true,
                      focusNode: _controller.usernameNode,
                      style: customTextStyle(),
                      cursorColor: Colors.blueAccent,
                      textInputAction: TextInputAction.next,
                      decoration: customTextDecoration(
                          Strings.usernameLabel, Icons.person, context),
                      textCapitalization: TextCapitalization.none,
                      onFieldSubmitted: (term) {
                        fieldFocusChange(context, _controller.usernameNode,
                            _controller.passwordNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return Strings.usernameEmptyMessage;
                        }
                        return null; // Return null for no error
                      },
                    ),
                    TextFormField(
                      enabled: true,
                      controller: _controller.passwordController,
                      obscureText: !_controller.passwordVisible.value,
                      textInputAction: TextInputAction.done,
                      style: customTextStyle(),
                      cursorColor: Colors.blueAccent,
                      focusNode: _controller.passwordNode,
                      decoration: customTextDecoration(
                          Strings.passwordLabel, Icons.lock, context,
                          secure: true),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return Strings.passwordEmptyMessage;
                        }
                        return null; // Return null for no error
                      },
                      onFieldSubmitted: (term) {
                        _controller.passwordNode.unfocus();
                        _controller.onLoginPressed(context);
                      },
                    ),
                    customSizedBox(height: 15.0),
                    Obx(() => Text(
                          _controller.errorMessage.value,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        )),
                    customSizedBox(height: 2.0),
                    loginButton(context),
                    customSizedBox(height: 30.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget loginButton(BuildContext context) {
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

  InputDecoration customTextDecoration(
      String text, IconData icon, BuildContext context,
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

  SizedBox customSizedBox({double height = 0.0, double width = 0.0}) {
    return SizedBox(
      height: height,
      width: width,
    );
  }

  void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    // Handle focus change logic here
  }
}
