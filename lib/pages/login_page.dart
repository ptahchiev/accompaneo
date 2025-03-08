import 'package:accompaneo/services/api_service.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import '../utils/helpers/snackbar_helper.dart';
import '../values/app_regex.dart';
import 'dart:convert' as convert;
import '../widgets/app_text_form_field.dart';
import '../resources/resources.dart';
import '../widgets/gradient_background.dart';
import '../utils/helpers/navigation_helper.dart';
import '../values/app_constants.dart';
import '../values/app_routes.dart';
import '../values/app_strings.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  void initializeControllers() {
    emailController = TextEditingController()..addListener(controllerListener);
    passwordController = TextEditingController()
      ..addListener(controllerListener);
  }

  void disposeControllers() {
    emailController.dispose();
    passwordController.dispose();
  }

  void controllerListener() {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty && password.isEmpty) return;

    if (AppRegex.emailRegex.hasMatch(email) &&
        AppRegex.passwordRegex.hasMatch(password)) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeControllers();
 }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }


  // Future<void> signInWithGoogle() async {
  //   await ApiService.loginWithGoogle();
  // }

  Future<void> signInWithFacebook() async {
    // final LoginResult loginResult = await FacebookAuth.instance.login();
    // print(loginResult);




  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          GradientBackground(
            children: [
              Text(
                AppStrings.signInToYourNAccount,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
              ),
              SizedBox(height: 6),
              Text(AppStrings.signInToYourAccount, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white)),
            ],
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppTextFormField(
                    controller: emailController,
                    labelText: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppStrings.pleaseEnterEmailAddress
                          : AppConstants.emailRegex.hasMatch(value)
                              ? null
                              : AppStrings.invalidEmailAddress;
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: passwordNotifier,
                    builder: (_, passwordObscure, __) {
                      return AppTextFormField(
                        obscureText: passwordObscure,
                        controller: passwordController,
                        labelText: AppStrings.password,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (_) => _formKey.currentState?.validate(),
                        validator: (value) {
                          return value!.isEmpty
                              ? AppStrings.pleaseEnterPassword
                              : AppConstants.passwordRegex.hasMatch(value)
                                  ? null
                                  : AppStrings.invalidPassword;
                        },
                        suffixIcon: IconButton(
                          onPressed: () =>
                              passwordNotifier.value = !passwordObscure,
                          style: IconButton.styleFrom(
                            minimumSize: const Size.square(48),
                          ),
                          icon: Icon(
                            passwordObscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () => NavigationHelper.pushReplacementNamed(
                      AppRoutes.forgotPassword,
                    ),
                    child: const Text(AppStrings.forgotPassword),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: fieldValidNotifier,
                    builder: (_, isValid, __) {
                      return FilledButton(
                        onPressed: isValid
                            ? () {
                                final result = ApiService.login(context, emailController.text, passwordController.text);
                                result.then((response) {
                                  if (response.statusCode == 200) {
                                    emailController.clear();
                                    passwordController.clear();
                                    NavigationHelper.pushReplacementNamed(AppRoutes.home);
                                  } else {
                                    var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
                                    if (jsonResponse['message'] != null) {
                                      SnackbarHelper.showSnackBar(jsonResponse['message'], isError: true);
                                    } else {
                                      SnackbarHelper.showSnackBar('Failed to login: ${response.statusCode}', isError: true);
                                    }
                                  }
                                });
                              }
                            : null,
                        child: const Text(AppStrings.login),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          AppStrings.orLoginWith,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            ApiService.loginWithGoogle().then((result) {
                              print(result);
                            });
                            // authProvider.handleGoogleSignIn().then((result) {
                            //   if (result) {
                            //     emailController.clear();
                            //     passwordController.clear();
                            //     NavigationHelper.pushReplacementNamed(AppRoutes.home);
                            //   } else {
                            //     SnackbarHelper.showSnackBar('Failed to login!', isError: true);
                            //   }
                            // });
                          },
                          icon: SvgPicture.asset(Vectors.google, width: 14),
                          label: const Text(
                            AppStrings.google,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            signInWithFacebook();


                            // authProvider.handleFacebookLogin().then((result) {
                            //   // if (result) {
                            //   //   emailController.clear();
                            //   //   passwordController.clear();
                            //   //   NavigationHelper.pushReplacementNamed(AppRoutes.home);
                            //   // } else {
                            //   //   SnackbarHelper.showSnackBar('Failed to login!', isError: true);
                            //   // }
                            // });
                          },
                          icon: SvgPicture.asset(Vectors.facebook, width: 14),
                          label: const Text(
                            AppStrings.facebook,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.doNotHaveAnAccount,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () => NavigationHelper.pushReplacementNamed(
                  AppRoutes.register,
                ),
                child: const Text(AppStrings.register),
              ),
            ],
          ),
        ],
      ),
    );
  }
}