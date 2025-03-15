import 'dart:convert' as convert;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:accompaneo/models/user/registration.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:flutter/material.dart';
import '../utils/helpers/navigation_helper.dart';
import '../utils/helpers/snackbar_helper.dart';
import '../values/app_constants.dart';
import '../values/app_regex.dart';
import '../values/app_routes.dart';
import '../widgets/app_text_form_field.dart';
import '../widgets/gradient_background.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> confirmPasswordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  void initializeControllers() {
    nameController = TextEditingController()..addListener(controllerListener);
    emailController = TextEditingController()..addListener(controllerListener);
    passwordController = TextEditingController()
      ..addListener(controllerListener);
    confirmPasswordController = TextEditingController()
      ..addListener(controllerListener);
  }

  void disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  void controllerListener() {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty &&
        email.isEmpty &&
        password.isEmpty &&
        confirmPassword.isEmpty) {
      return;
    }

    if (AppRegex.emailRegex.hasMatch(email) &&
        AppRegex.passwordRegex.hasMatch(password) &&
        AppRegex.passwordRegex.hasMatch(confirmPassword) &&
        password == confirmPassword) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          GradientBackground(
            children: [
              Text(AppLocalizations.of(context)!.register, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white)),
              SizedBox(height: 6),
              Text(AppLocalizations.of(context)!.createYourAccount, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppTextFormField(
                    autofocus: false,
                    labelText: AppLocalizations.of(context)!.name,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppLocalizations.of(context)!.pleaseEnterName
                          : value.length < 4
                              ? AppLocalizations.of(context)!.invalidName
                              : null;
                    },
                    controller: nameController,
                  ),
                  AppTextFormField(
                    labelText: AppLocalizations.of(context)!.email,
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppLocalizations.of(context)!.pleaseEnterEmailAddress
                          : AppConstants.emailRegex.hasMatch(value)
                              ? null
                              : AppLocalizations.of(context)!.invalidEmailAddress;
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: passwordNotifier,
                    builder: (_, passwordObscure, __) {
                      return AppTextFormField(
                        obscureText: passwordObscure,
                        controller: passwordController,
                        labelText: AppLocalizations.of(context)!.password,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (_) => _formKey.currentState?.validate(),
                        validator: (value) {
                          return value!.isEmpty
                              ? AppLocalizations.of(context)!.pleaseEnterPassword
                              : AppConstants.passwordRegex.hasMatch(value)
                                  ? null
                                  : AppLocalizations.of(context)!.invalidPassword;
                        },
                        suffixIcon: Focus(
                          /// If false,
                          ///
                          /// disable focus for all of this node's descendants
                          descendantsAreFocusable: false,

                          /// If false,
                          ///
                          /// make this widget's descendants un-traversable.
                          // descendantsAreTraversable: false,
                          child: IconButton(
                            onPressed: () =>
                                passwordNotifier.value = !passwordObscure,
                            style: IconButton.styleFrom(
                              minimumSize: const Size.square(48),
                            ),
                            icon: Icon(
                              passwordObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: confirmPasswordNotifier,
                    builder: (_, confirmPasswordObscure, __) {
                      return AppTextFormField(
                        labelText: AppLocalizations.of(context)!.confirmPassword,
                        controller: confirmPasswordController,
                        obscureText: confirmPasswordObscure,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (_) => _formKey.currentState?.validate(),
                        validator: (value) {
                          return value!.isEmpty
                              ? AppLocalizations.of(context)!.pleaseReEnterPassword
                              : AppConstants.passwordRegex.hasMatch(value)
                                  ? passwordController.text ==
                                          confirmPasswordController.text
                                      ? null
                                      : AppLocalizations.of(context)!.passwordNotMatched
                                  : AppLocalizations.of(context)!.invalidPassword;
                        },
                        suffixIcon: Focus(
                          /// If false,
                          ///
                          /// disable focus for all of this node's descendants.
                          descendantsAreFocusable: false,

                          /// If false,
                          ///
                          /// make this widget's descendants un-traversable.
                          // descendantsAreTraversable: false,
                          child: IconButton(
                            onPressed: () => confirmPasswordNotifier.value =
                                !confirmPasswordObscure,
                            style: IconButton.styleFrom(
                              minimumSize: const Size.square(48),
                            ),
                            icon: Icon(
                              confirmPasswordObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: fieldValidNotifier,
                    builder: (_, isValid, __) {
                      return FilledButton(
                          onPressed: isValid
                              ? () {
                                  final result = ApiService.register(
                                      Registration(
                                          name: nameController.text,
                                          username: emailController.text,
                                          password: passwordController.text,
                                          repeatPassword:
                                              confirmPasswordController.text));
                                  result.then((response) {
                                    if (response.statusCode == 200) {
                                      nameController.clear();
                                      emailController.clear();
                                      passwordController.clear();
                                      confirmPasswordController.clear();
                                      NavigationHelper.pushReplacementNamed(
                                        AppRoutes.login,
                                      );
                                      SnackbarHelper.showSnackBar('Registered');
                                    } else {
                                      var jsonResponse =
                                          convert.jsonDecode(response.body)
                                              as Map<String, dynamic>;
                                      if (jsonResponse['message'] != null) {
                                        SnackbarHelper.showSnackBar(
                                            jsonResponse['message'],
                                            isError: true);
                                      } else {
                                        SnackbarHelper.showSnackBar(
                                            'Failed to fetch post: ${response.statusCode}',
                                            isError: true);
                                      }
                                    }
                                  });
                                }
                              : null,
                          child: Text(AppLocalizations.of(context)!.register));
                    },
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.iHaveAnAccount,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              TextButton(
                onPressed: () => NavigationHelper.pushReplacementNamed(
                  AppRoutes.login,
                ),
                child: Text(AppLocalizations.of(context)!.login),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
