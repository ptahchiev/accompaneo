import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String nemesisTokenHeader = 'X-Nemesis-Token';

  static const String urlEndpoint = 'https://api.accompaneo.org/facade';

  //static const String urlEndpoint = 'http://localhost:8111/storefront/facade';

  //static const String urlEndpoint = 'http://192.168.0.104:8111/storefront/facade';

  static final navigationKey = GlobalKey<NavigatorState>();

  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.([a-zA-Z]{2,})+",
  );

  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$#!%*?&_])[A-Za-z\d@#$!%*?&_].{7,}$',
  );
}
