import 'dart:convert';
import 'package:galaxy_store/config/global.dart';
import 'package:galaxy_store/models/Complete.dart';
import 'package:http/http.dart' as http;

class CompleteController {
  static getComplete(CompleteSubmit res) async {
    var body = res.toMap();
    return http
        .post(apiDeliveryUpdateUrl, body: body)
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return CompleteReturn.fromJson(json.decode(response.body));
    });
  }
}
