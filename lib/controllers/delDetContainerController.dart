import 'dart:convert';
import 'package:galaxy_store/config/global.dart';
import 'package:galaxy_store/models/delDetContainer.dart';
import 'package:http/http.dart' as http;

class DelDetContainerController {
  static getDelDetContainer(DelDetContainerSubmit res) async {
    var body = res.toMap();
    return http
        .post(apiDelDetContainerUrl, body: body)
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return DelDetContainerReturn.fromJson(json.decode(response.body));
    });
  }
}
