import 'dart:async';

import 'package:accompaneo/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/helpers/snackbar_helper.dart';
import '../values/app_constants.dart';
import '../values/app_regex.dart';
import '../widgets/app_text_form_field.dart';

// This class handles the Page to dispaly the user's info on the "Edit Profile" Screen
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  void initializeControllers() {
    nameController = TextEditingController()..addListener(controllerListener);
    emailController = TextEditingController()..addListener(controllerListener);
    passwordController = TextEditingController()
      ..addListener(controllerListener);
  }

  void disposeControllers() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void controllerListener() {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;

    if (name.isEmpty && email.isEmpty && password.isEmpty) return;

    if (name.isNotEmpty &&
        name.length >= 2 &&
        AppRegex.emailRegex.hasMatch(email) &&
        (password.isEmpty || AppRegex.passwordRegex.hasMatch(password))) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  @override
  void initState() {
    initializeControllers();
    ApiService.getUserProfile().then((result) {
      emailController.value = TextEditingValue(text: result['email'] ?? '');
      nameController.value = TextEditingValue(text: result['name'] ?? '');
    });
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
        children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.updateYourProfile,
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                ],
              )),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppTextFormField(
                    readOnly: true,
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
                  AppTextFormField(
                    autofocus: false,
                    labelText: AppLocalizations.of(context)!.name,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    validator: (value) {
                      return value!.isEmpty
                          ? AppLocalizations.of(context)!.pleaseEnterName
                          : value.length < 2
                              ? AppLocalizations.of(context)!.invalidName
                              : null;
                    },
                    controller: nameController,
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
                          return value!.isEmpty ||
                                  AppConstants.passwordRegex.hasMatch(value)
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
                                ApiService.updateUserProfile({
                                  'name': nameController.text,
                                  'password': passwordController.text
                                }).then((result) {
                                  SnackbarHelper.showSnackBar(
                                    AppLocalizations.of(context)!.profileUpdated,
                                  );
                                });
                              }
                            : null,
                        child: Text(AppLocalizations.of(context)!.submit),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Refrshes the Page after updating user info.
  FutureOr onGoBack(dynamic value) {
    setState(() {});
  }
}
