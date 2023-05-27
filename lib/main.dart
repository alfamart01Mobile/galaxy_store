import 'package:flutter/material.dart';
import 'package:galaxy_store/pages/checking/checking.dart';
import 'package:galaxy_store/pages/login/loginView.dart';

var proxyHost;
var proxyPort;

main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    routes: {
      "/": (BuildContext context) => LoginView(),
      "/checking": (BuildContext context) => CheckingView(),
    },
  ));
}
