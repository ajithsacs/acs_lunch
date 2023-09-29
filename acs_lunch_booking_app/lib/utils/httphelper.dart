import 'dart:convert';
import 'package:get/get.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../appconstant/endpoints.dart';
import '../appconstant/preferences.dart';
import '../appconstant/strings.dart';
import 'databasehelper.dart';
import 'settings.dart';
import 'package:http/http.dart' as http;

enum HttpMethods { get, post, put, delete, authentication }
enum ResponseStatus { success, error, conflict }

class HttpController extends GetxController {
  late SharedPreferences sharedPreferences;
  late String authToken;

  static HttpController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // Initialize any dependencies or variables here
  }

  Future<String?> getToken() async {
    sharedPreferences = await SharedPreferences.getInstance();
    authToken = sharedPreferences.getString(Preferences.auth_token)!;
    if (authToken != null) {
      //log.v("token $authToken");
      return authToken;
    } else {
      return null;
    }
  }

  Future<String> getAdminToken() async {
    return "YXBpX3VzZXI6QWNzQDIwMTc=";
  }

  Map<String, dynamic> provideResponse({
    bool success = false,
    dynamic data,
    String message = "No message present",
    ResponseStatus status = ResponseStatus.error,
  }) {
    return {
      "success": success,
      "message": message,
      "data": data,
      "status": status,
    };
  }

  Future<Map> isNetworkAvailable() async {
    Map connectionStatus;
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      connectionStatus = {"status": true, "connectionType": "mobile"};
    } else if (connectivityResult == ConnectivityResult.wifi) {
      connectionStatus = {"status": true, "type": "wifi"};
    } else {
      connectionStatus = {"status": false, "type": null};
    }
    return connectionStatus;
  }

  Future<bool> replaceToken() async {
    sharedPreferences = await SharedPreferences.getInstance();
    var oldRefreshToken = sharedPreferences.getString(Preferences.refresh_token);
    // log.d("refresh token is $oldRefreshToken");
    if (oldRefreshToken == null) {
      // log.d("refresh token failed");
      logout();
      return false;
    }
    var data = {
      "refresh_token": oldRefreshToken,
      "grant_type": "refresh_token"
    };
    var response = await authRequest(
      endPoint: Endpoints.refreshToken,
      data: json.encode(data),
    );
   // log.d("new refresh token response $response");
    if (response['success']) {
      var authToken = response['data']['access_token'];
      var refreshToken = response['data']['refresh_token'];
      sharedPreferences.setString(Preferences.auth_token, authToken);
      sharedPreferences.setString(Preferences.refresh_token, refreshToken);
      return true;
    } else {
      //log.d("refresh token failed");
      logout();
      var error = response['data'] != null ? (response['data']['error'] ?? "") : "";
      if (error == "invalid_grant") {
        logout();
      }
      return false;
    }
  }

  void logout() async {
    sharedPreferences.setString(Preferences.auth_token, '');
    DatabaseHelper.instance.deleteDb;
    // Globals().navigatorKey.currentState.pushReplacementNamed('/loginScreen');
  }

  Map<String, dynamic> catchError(dynamic error) {
    if (error == null ||
        error.message == null ||
        error.message.runtimeType == String ||
        error.message["statuscode"] != 400 ||
        error.message["message"] == null ||
        error.message["message"]["errors"] == null) {
      return provideResponse(
        success: false,
        message: Strings.errorMessage,
        status: ResponseStatus.error,
      );
    } else {
      return provideResponse(
        success: false,
        message: error.message["message"]["errors"]["message"],
        status: ResponseStatus.error,
      );
    }
  }

  Future request(
    HttpMethods requestType, {
    String baseUrl = Settings.baseUrl,
    String endPoint = "",
    dynamic data,
    bool authenticationRequired = false,
    int tryCount = 0,
    bool isAdmin = false,
  }) async {
    var endPointURL = baseUrl + endPoint;
    // log.d("$requestType url is $endPointURL data is $data");
    var networkAvailability = await isNetworkAvailable();

    if (networkAvailability["status"] == true) {
      var token = isAdmin ? await getAdminToken() : await getToken();
      print("set $token");
      if (token != null || !authenticationRequired) {
        try {
          http.Response response;
          Map<String, String> header = {"Content-Type": "application/json"};
          if (authenticationRequired) header["Authorization"] = "Basic $token";

          switch (requestType) {
            case HttpMethods.get:
              response = await http
                  .get(endPointURL as Uri, headers: header)
                  .timeout(Settings.httpRequestTimeout);
              break;
            case HttpMethods.post:
              response = await http
                  .post(endPointURL as Uri, body: data, headers: header)
                  .timeout(Settings.httpRequestTimeout);
              break;
            case HttpMethods.put:
              response = await http
                  .put(endPointURL as Uri, body: data, headers: header)
                  .timeout(Settings.httpRequestTimeout);
              break;
            case HttpMethods.delete:
              response = await http
                  .delete(endPointURL as Uri, headers: header)
                  .timeout(Settings.httpRequestTimeout);
              break;
            default:
              throw Exception();
          }

          switch (response.statusCode) {
            case 200:
              {
                var extractData;
                if (response.body == "") {
                  extractData = null;
                } else {
                  extractData = json.decode(response.body);
                }
                return provideResponse(
                  success: true,
                  data: extractData,
                  status: ResponseStatus.success,
                );
              }
            case 401:
              {
                var replaceTokenResponse = await replaceToken();
                if (replaceTokenResponse) {
                  tryCount++;
                  if (tryCount < 3) {
                    return request(
                      requestType,
                      baseUrl: baseUrl,
                      endPoint: endPoint,
                      data: data,
                      authenticationRequired: authenticationRequired,
                      tryCount: tryCount,
                    );
                  } else {
                    //TODO: logout
                  }
                } else {
                  //TODO: logout
                  throw Exception();
                }
              }
              break;
            case 403:
              {
                tryCount++;
                if (tryCount < 3) {
                  return request(
                    requestType,
                    baseUrl: baseUrl,
                    endPoint: endPoint,
                    data: data,
                    authenticationRequired: authenticationRequired,
                    tryCount: tryCount,
                  );
                } else {
                  //TODO: logout
                }
              }
              break;
            case 409:
              {
                // log.d('yes5');
                var extractdata = json.decode(response.body);
                return provideResponse(
                  success: false,
                  data: extractdata,
                  status: ResponseStatus.conflict,
                );
              }
              // break;
            case 201:
              {
                // log.d('yes4');
                var extractdata = json.decode(response.body);
                return provideResponse(
                  success: true,
                  data: extractdata,
                  status: ResponseStatus.success,
                );
              }
            
            default:
              {
             
                throw Exception({
                  "statuscode": response.statusCode,
                  "message": json.decode(response.body),
                });
              }
          }
        } catch (e) {
          return catchError(e);
        }
      } else {
      
        return provideResponse(
          success: false,
          message: Strings.errorMessage,
          status: ResponseStatus.error,
        );
      }
    } else {
  
      return provideResponse(
        success: false,
        message: Strings.internetNotAvailable,
        status: ResponseStatus.error,
      );
    }
  }

  Future<Map<String, dynamic>> authRequest({
    String baseUrl = Settings.baseUrl,
    String endPoint = "",
    dynamic data,
  }) async {
    var endPointURL = baseUrl + endPoint;
    print("endPointURL $endPointURL body  ${data.runtimeType}");
    var networkAvailability = await isNetworkAvailable();
    print("network $networkAvailability");
    if (networkAvailability["status"] == true) {
      try {
        final response = await http.post(endPointURL as Uri, body: data, headers: {
          "Content-Type": "application/json",
        }).timeout(Settings.httpRequestTimeout);

        print(
            "$endPoint response is ${response.statusCode} and body ${response.body}");
        switch (response.statusCode) {
          case 200:
            {
              var extractdata = json.decode(response.body);
              return provideResponse(
                success: true,
                data: extractdata,
                status: ResponseStatus.success,
              );
            }
            break;
          case 401:
            {
              var extractdata = json.decode(response.body);
              return provideResponse(
                success: false,
                data: extractdata,
                status: ResponseStatus.error,
              );
            }
            break;
          case 403:
            {
              var extractdata = json.decode(response.body);
              return provideResponse(
                success: false,
                data: extractdata,
                status: ResponseStatus.error,
              );
            }
            break;
          default:
            {
              var extractdata = json.decode(response.body);
              return provideResponse(
                success: false,
                data: extractdata,
                status: ResponseStatus.error,
              );
            }
        }
      } catch (e) {
        print("Some exception occurred $e");
        return provideResponse(
          success: false,
          message: e.toString(),
          status: ResponseStatus.error,
        );
      }
    } else {
      return provideResponse(
        success: false,
        message: Strings.internetNotAvailable,
        status: ResponseStatus.error,
      );
    }
  }
}
