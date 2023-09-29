
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_screen.respository.dart';

class Model extends GetxController {
  var isLoading = false.obs;
  var isAutoValidateMode = false.obs;
  var usernameNode = FocusNode();
  var passwordNode = FocusNode();
  var errorMessage = ''.obs;
  var formKey = GlobalKey<FormState>();
  var userNameController = TextEditingController();
  var passwordController = TextEditingController();
  var loginUserName = ''.obs;
  var loginId = 0.obs;
  var mySharedPreferences = SharedPreferences.getInstance().obs;
  var internetSubscription;
  var isInternetAvailable = true.obs;
  var backButtonPressTime = DateTime.now().obs;
  late AuthScreenRepository loginRepo;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  login() async {
    return await loginRepo.loginUser();
  }
}
