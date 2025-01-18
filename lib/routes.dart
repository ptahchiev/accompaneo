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
    switch (settings.name) {
      case AppRoutes.login:
        return SlideRightRoute(widget: const LoginPage());

      case AppRoutes.register:
        return SlideRightRoute(widget: const RegisterPage());

      case AppRoutes.forgotPassword:
        return SlideRightRoute(widget: const ForgotPasswordPage());  

      case AppRoutes.home:
        return SlideRightRoute(widget: const HomePage(title: ''));              

      /// An invalid route. User shouldn't see this,
      /// it's for debugging purpose only.
      default:
        return SlideRightRoute(widget: const InvalidRoute());
    }
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget widget;
  SlideRightRoute({required  this.widget})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
}