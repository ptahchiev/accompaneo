import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/settings_data.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/utils/helpers/snackbar_helper.dart';
import 'package:accompaneo/values/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);
  late final TextEditingController themeModeController;
  late final TextEditingController colorController;
  late final TextEditingController languageController;
  late final TextEditingController instrumentController;
  late final TextEditingController countInEffectController;

  final _formKey = GlobalKey<FormState>();

  final List<bool> _selectedThemes = [false, false];
  final List<bool> _selectedInstruments = <bool>[false, false, false];

  String? languageValue;
  String? countInEffectValue;

  List<Color> colorHistory = [];
  Color currentColor = Colors.amber;
  List<Color> currentColors = [Colors.yellow, Colors.green];

  void changeColor(Color color) => setState(() => currentColor = color);
  void changeColors(List<Color> colors) => setState(() => currentColors = colors);

  void initializeControllers() {
    themeModeController = TextEditingController()..addListener(controllerListener);
    colorController = TextEditingController()..addListener(controllerListener);
    languageController = TextEditingController()..addListener(controllerListener);
    instrumentController = TextEditingController()..addListener(controllerListener);
    countInEffectController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    themeModeController.dispose();
    colorController.dispose();
    languageController.dispose();
    instrumentController.dispose();
    countInEffectController.dispose();
  }

  void controllerListener() {
    final themeMode = themeModeController.text;
    final color = colorController.text;
    final language = languageController.text;
    final instrument = instrumentController.text;

    if (themeMode.isEmpty && color.isEmpty &&
        language.isEmpty &&
        instrument.isEmpty) return;

    fieldValidNotifier.value = true;
  }

  @override
  void initState() {
    super.initState();
    initializeControllers();

    // themeModeController.value = TextEditingValue(text: settingsData.themeMode);
    // languageController.value = TextEditingValue(text: settingsData.sessionLocale.languageCode);
    // instrumentController.value = TextEditingValue(text: settingsData.instrumentType);
    // countInEffectController.value = TextEditingValue(text: settingsData.countInEffect);
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:  ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.settings,
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                ],
            )),          
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.theme),
                    Padding(
                      padding: EdgeInsets.only(bottom:20),
                      child: ToggleButtons(
                        direction: Axis.horizontal,
                        onPressed: (int index) {
                          setState(() {
                            for (int i = 0; i < _selectedThemes.length; i++) {
                              _selectedThemes[i] = i == index;
                            }
                          });
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: AppColors.primaryColor,
                        selectedColor: Colors.white,
                        fillColor: AppColors.primaryColor,
                        color: AppColors.primaryColor,
                        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
                        isSelected: _selectedThemes.contains(true) ? _selectedThemes : [Provider.of<PlaylistsModel>(context, listen: false).getSettings().themeMode == 'LIGHT', Provider.of<PlaylistsModel>(context, listen: false).getSettings().themeMode == 'DARK'],
                        children: getThemeModeEntries(context),
                      ),
                    ),

                    Text(AppLocalizations.of(context)!.instrument, style : Theme.of(context).textTheme.titleSmall),
                    Padding(
                      padding: EdgeInsets.only(bottom:20),
                      child: ToggleButtons(
                        direction: Axis.horizontal,
                        onPressed: (int index) {
                          setState(() {
                            for (int i = 0; i < _selectedInstruments.length; i++) {
                              _selectedInstruments[i] = i == index;
                            }
                          });
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: AppColors.primaryColor,
                        selectedColor: Colors.white,
                        fillColor: AppColors.primaryColor,
                        color: AppColors.primaryColor,
                        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 80.0),
                        isSelected: _selectedInstruments.contains(true) ? _selectedInstruments : [Provider.of<PlaylistsModel>(context, listen: false).getSettings().instrumentType == 'PIANO', Provider.of<PlaylistsModel>(context, listen: false).getSettings().instrumentType == 'GUITAR', Provider.of<PlaylistsModel>(context, listen: false).getSettings().instrumentType == 'UKULELE'],
                        children: getInstrumentEntries(context),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom:20),
                      child: DropdownMenu(
                        controller: languageController,
                        expandedInsets: EdgeInsets.zero,
                        dropdownMenuEntries: getLanguageEntries(context),
                        initialSelection: languageValue ?? Provider.of<PlaylistsModel>(context, listen: true).getSettings().sessionLocale.languageCode,
                        requestFocusOnTap: true,
                        label: Text(AppLocalizations.of(context)!.language),
                        onSelected: (value) {
                          setState(() {
                            languageValue = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom:20),
                      child: DropdownMenu(
                        controller: countInEffectController,
                        expandedInsets: EdgeInsets.zero,
                        enableSearch: false,
                        dropdownMenuEntries: getCountInEntries(context),
                        initialSelection: countInEffectValue ?? Provider.of<PlaylistsModel>(context, listen: true).getSettings().countInEffect,
                        requestFocusOnTap: true,
                        label: Text(AppLocalizations.of(context)!.countInEffect),
                        onSelected: (value) {
                          setState(() {
                            countInEffectValue = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: ValueListenableBuilder(
                        valueListenable: fieldValidNotifier,
                        builder: (_, isValid, __) {
                          return FilledButton(
                            onPressed: isValid
                                ? () {
                                    SettingsData settingsData = SettingsData(
                                      themeMode: getSelectedThemeMode(), 
                                      instrumentType: getSelectedInstrument(),
                                      countInEffect: countInEffectValue ?? Provider.of<PlaylistsModel>(context, listen: false).getSettings().countInEffect, 
                                      sessionLocale: languageValue != null ? Locale(languageValue!) : Provider.of<PlaylistsModel>(context, listen: false).getSettings().sessionLocale
                                    );
                                  
                                    final result = ApiService.updateSettings(settingsData);
                                    
                                    result.then((response) {
                                      Provider.of<PlaylistsModel>(context, listen: false).setSettingsData(settingsData);
                                      SnackbarHelper.showSnackBar(
                                        AppLocalizations.of(context)!.settingsUpdated,
                                      );
                                    });       
                                  }
                                : null,
                            child: Text(AppLocalizations.of(context)!.submit),
                          );
                        },
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                      },
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty<Color>.fromMap(
                          <WidgetStatesConstraint, Color>{
                            WidgetState.focused: Colors.white,
                            WidgetState.selected : Colors.white,
                            WidgetState.disabled: Colors.black,
                            WidgetState.any: Colors.white,
                          }
                        ),
                        backgroundColor: WidgetStateProperty<Color>.fromMap(
                            <WidgetStatesConstraint, Color>{
                              WidgetState.focused: Colors.white,
                              WidgetState.disabled: Colors.grey.shade400,
                              WidgetState.selected : Colors.red,
                              WidgetState.any: Colors.red,
                            }
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.cancelSubscription),
                    )
                  ],
                ),
              ),
            ),

          ],
        )
    );
  }

  String getSelectedThemeMode() {
    if (_selectedThemes[0]) {
      return "LIGHT";
    }
    if (_selectedThemes[1]) {
      return "DARK";
    }
    return Provider.of<PlaylistsModel>(context, listen: false).getSettings().themeMode;
  }

  String getSelectedInstrument() {
    if (_selectedInstruments[0]) {
      return "PIANO";
    }
    if (_selectedInstruments[1]) {
      return "GUITAR";
    }
    if (_selectedInstruments[2]) {
      return "UKULELE";
    }
    return Provider.of<PlaylistsModel>(context, listen: false).getSettings().instrumentType;
  }
  
  List<Widget> getThemeModeEntries(BuildContext context) {
    return  [
      Wrap(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Icon(Icons.light_mode)
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            child: Text(AppLocalizations.of(context)!.light)
          )

        ]
      ),
      Wrap(
        children: [
          Padding(
            padding:EdgeInsets.symmetric(horizontal: 5),
            child: Icon(Icons.dark_mode),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            child: Text(AppLocalizations.of(context)!.dark)
          )
        ]
      ),
    ];
  }

  List<Widget> getInstrumentEntries(BuildContext context) {
    return  [
      Text(AppLocalizations.of(context)!.piano),
      Text(AppLocalizations.of(context)!.guitar),
      Text(AppLocalizations.of(context)!.ukulele)
    ];
  }  

  List<DropdownMenuEntry> getLanguageEntries(BuildContext context) {
    return [
      DropdownMenuEntry(leadingIcon: CountryFlag.fromCountryCode('US', width: 30, height:20), value: 'en', label: AppLocalizations.of(context)!.en), 
      DropdownMenuEntry(leadingIcon: CountryFlag.fromCountryCode('BG', width: 30, height: 20), value: 'bg', label: AppLocalizations.of(context)!.bg),
      DropdownMenuEntry(leadingIcon: CountryFlag.fromCountryCode('ES', width: 30, height: 20), value: 'es', label: AppLocalizations.of(context)!.es)
    ];
  }

  List<DropdownMenuEntry> getCountInEntries(BuildContext context) {
    return [
      DropdownMenuEntry(value: 'FINGERCLICK', label: AppLocalizations.of(context)!.fingerclick), 
      DropdownMenuEntry(value: 'METRONOME', label: AppLocalizations.of(context)!.metronome)
    ];
  }
}