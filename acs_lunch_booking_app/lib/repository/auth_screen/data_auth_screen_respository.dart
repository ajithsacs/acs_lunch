


import '../../appconstant/endpoints.dart';
import '../../login/auth_screen.respository.dart';
import '../../utils/httphelper.dart';

HttpController httpHelper = HttpController();


class DataAuthScreenRepository implements AuthScreenRepository {
  loginUser() async {
    return await httpHelper.request(
      HttpMethods.get,
      endPoint: Endpoints.loginUrl,
      authenticationRequired: true,
    );
  }
}
