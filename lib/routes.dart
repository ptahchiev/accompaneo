import 'package:accompaneo/pages/home_page.dart';
import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'widgets/invalid_route.dart';
import 'values/app_routes.dart';

class Routes {
  const Routes._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Route<dynamic> getRoute({
      required Widget widget,
      bool fullscreenDialog = false,
    }) {
      return MaterialPageRoute<void>(
        builder: (context) => widget,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
      );
    }

    switch (settings.name) {
      case AppRoutes.login:
        return getRoute(widget: const LoginPage());

      case AppRoutes.register:
        return getRoute(widget: const RegisterPage());

      case AppRoutes.forgotPassword:
        return getRoute(widget: const ForgotPasswordPage());  

      case AppRoutes.home:
        return getRoute(widget: const HomePage(title: ''));              

      /// An invalid route. User shouldn't see this,
      /// it's for debugging purpose only.
      default:
        return getRoute(widget: const InvalidRoute());
    }
  }
}