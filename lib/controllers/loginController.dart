import 'dart:convert';
import 'package:galaxy_store/config/global.dart';
import 'package:galaxy_store/models/login.dart';
import 'package:http/http.dart' as http;
import 'package:galaxy_store/config/session.dart' as session;

class LoginController {
  static getUser(LoginSubmit res) async {
    var body = res.toMap();
    return http.post(apiLoginUrl, body: body).then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return LoginReturn.fromJson(json.decode(response.body));
    });
  }
}
