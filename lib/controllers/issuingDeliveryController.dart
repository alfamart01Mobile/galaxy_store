import 'dart:convert';
import 'package:galaxy_store/config/global.dart';
import 'package:galaxy_store/models/issuingDelivery.dart';
import 'package:http/http.dart' as http;

class IssuingDeliveryController {
  static getIssuingDelivery(IssuingDeliverySubmit res) async {
    var body = res.toMap();
    return http
        .post(apiIssuingDeliveryUrl, body: body)
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return IssuingDeliveryReturn.fromJson(json.decode(response.body));
    });
  }
}
