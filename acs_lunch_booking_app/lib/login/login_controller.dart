import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../appconstant/preferences.dart';
import '../homescreen/homescreen.dart';
import '../utils/httphelper.dart';
import 'login_model.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final usernameNode = FocusNode();
  final passwordNode = FocusNode();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isLoading = false.obs;
  final isAutoValidateMode = false.obs;
  final loginUserName = "".obs;
  final loginId = 0.obs;
  final backButtonPressTime = DateTime.now().obs;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Use RxBool to manage password visibility
  final passwordVisible = false.obs;
  final errorMessage = "".obs;
  final isInternetAvailable = true.obs; // Assuming internet is initially available

  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        isInternetAvailable.value = false;
      } else {
        isInternetAvailable.value = true;
      }
    });
  }

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  Future<bool> onWillPop() async {
    // Handle back button logic here
    exit(0);
    return false; // true sends it to previous page
  }

  void onLoginPressed(BuildContext context) {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      isLoading.value = true;
      login(context);
    } else {
      isAutoValidateMode.value = true;
    }
  }

  void login(BuildContext context) async {
    isLoading.value = true;

    String params = base64.encode(utf8.encode("${userNameController.text}:${passwordController.text}"));
    saveValueToSharedPreferences(Preferences.auth_token, params);

    var response = Model().login();

    if (response['status'] == ResponseStatus.success) {
      var data = response['data']['user'];
      loginUserName.value = data['firstname'];
      loginId.value = data['id'];

    saveValueToSharedPreferences(Preferences.login_token, loginUserName.value);
    saveValueToSharedPreferences('loginTokenId', loginId.value as String);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    } else {
      isLoading.value = false;
      Fluttertoast.showToast(
  msg: "Incorrect Username or Password",
  toastLength: Toast.LENGTH_LONG,
  gravity: ToastGravity.BOTTOM, // You can change the gravity as needed
  timeInSecForIosWeb: 3,
  backgroundColor: Colors.red,
  textColor: Colors.white,
  fontSize: 28.0,
);
    }
  }
}
Future<void> saveValueToSharedPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }