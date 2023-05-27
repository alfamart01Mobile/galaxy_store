import 'dart:convert';
import 'package:galaxy_store/config/global.dart';
import 'package:galaxy_store/models/shippingupdate.dart';
import 'package:http/http.dart' as http;

class ShippingUpdateController {
  static getShippingUpdate(ShippingUpdateSubmit res) async {
    var body = res.toMap();
    return http
        .post(apiShippingUpdateUrl, body: body)
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return ShippingUpdateReturn.fromJson(json.decode(response.body));
    });
  }
}
