import 'package:accompaneo/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/helpers/snackbar_helper.dart';

import '../widgets/app_text_form_field.dart';
import '../widgets/gradient_background.dart';
import '../utils/helpers/navigation_helper.dart';
import '../values/app_constants.dart';
import '../values/app_regex.dart';
import '../values/app_routes.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController emailController;

  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> confirmPasswordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  void initializeControllers() {
    emailController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    emailController.dispose();
  }

  void controllerListener() {
    final email = emailController.text;

    if (email.isEmpty) return;

    if (AppRegex.emailRegex.hasMatch(email)) {
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
              Text(AppLocalizations.of(context)!.forgotPassword, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white)),
              SizedBox(height: 6),
              Text(AppLocalizations.of(context)!.enterYourEmail, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white)),
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
                  ValueListenableBuilder(
                    valueListenable: fieldValidNotifier,
                    builder: (_, isValid, __) {
                      return FilledButton(
                        onPressed: isValid
                            ? () {
                                final result = ApiService.recoverPassword(emailController.text);
                                result.then((response) => {
                                  if (response.statusCode == 200) {
                                    emailController.clear(),
                                    NavigationHelper.pushReplacementNamed(
                                      AppRoutes.login,
                                    ),
                                    SnackbarHelper.showSnackBar('We sent you email with instructions')
                                  } else {
                                    SnackbarHelper.showSnackBar('Failed to fetch post: ${response.statusCode}', isError: true)
                                  }
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