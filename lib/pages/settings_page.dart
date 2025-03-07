import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/models/settings_data.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:accompaneo/utils/helpers/snackbar_helper.dart';
import 'package:accompaneo/values/app_strings.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
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

  final List<DropdownMenuEntry> themeModeEntries = [
    DropdownMenuEntry(value: 'DARK', label: 'Dark'), 
    DropdownMenuEntry(value: 'LIGHT', label: 'Light')
  ];

  final List<DropdownMenuEntry> languageEntries = [DropdownMenuEntry(value: 'en', label: 'English'), DropdownMenuEntry(value: 'bg', label: 'Bulgarian')];
  final List<DropdownMenuEntry> instrumentEntries = [
    DropdownMenuEntry(value: 'PIANO', label: 'Piano'), 
    DropdownMenuEntry(value: 'GUITAR', label: 'Guitar'),
    DropdownMenuEntry(value: 'UKULELE', label: 'Ukulele'),
  ];
  
  final List<DropdownMenuEntry> countInEffectEntries = [
    DropdownMenuEntry(value: 'FINGERCLICK', label: 'Fingerclick'), 
    DropdownMenuEntry(value: 'METRONOME', label: 'Metronome')
  ];

  String themeModeValue = 'LIGHT';
  String languageValue = 'en';
  String instrumentValue = 'PIANO';
  String countInEffectValue = 'FINGERCLICK';

  late Color dialogSelectColor = Colors.red;

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

    SettingsData settingsData = Provider.of<PlaylistsModel>(context, listen: false).getSettings();
    setState(() {
      themeModeValue = settingsData.themeMode;
      languageValue = settingsData.sessionLocale.languageCode;
      instrumentValue = settingsData.instrumentType;
      countInEffectValue = settingsData.countInEffect;
    });

    themeModeController.value = TextEditingValue(text: settingsData.themeMode);
    languageController.value = TextEditingValue(text: settingsData.sessionLocale.languageCode);
    instrumentController.value = TextEditingValue(text: settingsData.instrumentType);
    countInEffectController.value = TextEditingValue(text: settingsData.countInEffect);
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
                    AppStrings.settings,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.black),
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
                    ColorIndicator(
                      width: 40,
                      height: 40,
                      borderRadius: 0,
                      color: dialogSelectColor,
                      elevation: 1,
                      onSelectFocus: false,
                      onSelect: () async {
                        // Wait for the dialog to return color selection result.
                        final Color newColor = await showColorPickerDialog(
                          // The dialog needs a context, we pass it in.
                          context,
                          // We use the dialogSelectColor, as its starting color.
                          dialogSelectColor,
                          title: Text('ColorPicker', style: Theme.of(context).textTheme.titleLarge),
                          width: 40,
                          height: 40,
                          spacing: 0,
                          runSpacing: 0,
                          borderRadius: 0,
                          wheelDiameter: 165,
                          enableOpacity: true,
                          showColorCode: true,
                          colorCodeHasColor: true,
                          pickersEnabled: <ColorPickerType, bool> {
                            ColorPickerType.wheel: true,
                          },
                          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                            copyButton: true,
                            pasteButton: true,
                            longPressMenu: true,
                          ),
                          actionButtons: const ColorPickerActionButtons(
                            okButton: true,
                            closeButton: true,
                            dialogActionButtons: false,
                          ),
                          transitionBuilder: (BuildContext context,
                              Animation<double> a1,
                              Animation<double> a2,
                              Widget widget) {
                            final double curvedValue =
                                Curves.easeInOutBack.transform(a1.value) - 1.0;
                            return Transform(
                              transform: Matrix4.translationValues(
                                  0.0, curvedValue * 200, 0.0),
                              child: Opacity(
                                opacity: a1.value,
                                child: widget,
                              ),
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                          constraints: const BoxConstraints(minHeight: 480, minWidth: 320, maxWidth: 320),
                        );
                        // We update the dialogSelectColor, to the returned result
                        // color. If the dialog was dismissed it actually returns
                        // the color we started with. The extra update for that
                        // below does not really matter, but if you want you can
                        // check if they are equal and skip the update below.
                        setState(() {
                          dialogSelectColor = newColor;
                        });
                      }
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom:20),
                      child: DropdownMenu(
                        controller: themeModeController,
                        expandedInsets: EdgeInsets.zero,
                        dropdownMenuEntries: themeModeEntries,
                        initialSelection: themeModeValue,
                        requestFocusOnTap: true,
                        label: const Text('Theme'),
                        onSelected: (value) {
                          setState(() {
                            themeModeValue = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom:20),
                      child: DropdownMenu(
                        controller: languageController,
                        expandedInsets: EdgeInsets.zero,
                        dropdownMenuEntries: languageEntries,
                        initialSelection: languageValue,
                        requestFocusOnTap: true,
                        label: const Text('Language'),
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
                        controller: instrumentController,
                        expandedInsets: EdgeInsets.zero,
                        enableSearch: false,
                        dropdownMenuEntries: instrumentEntries,
                        initialSelection: instrumentValue,
                        requestFocusOnTap: true,
                        label: const Text('Instrument'),
                        onSelected: (value) {
                          setState(() {
                            instrumentValue = value;
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
                        dropdownMenuEntries: countInEffectEntries,
                        initialSelection: countInEffectValue,
                        requestFocusOnTap: true,
                        label: const Text('Count-in effect'),
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
                                      themeMode: themeModeValue, 
                                      instrumentType: instrumentValue, 
                                      countInEffect: countInEffectValue, 
                                      sessionLocale: Locale(languageValue)
                                    );
                                  
                                    final result = ApiService.updateSettings(settingsData);
                                    
                                    result.then((response) {
                                      Provider.of<PlaylistsModel>(context, listen: false).setSettingsData(settingsData);
                                      SnackbarHelper.showSnackBar(
                                        'Settings updated!',
                                      );
                                    });       
                                  }
                                : null,
                            child: const Text(AppStrings.submit),
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
                      child: const Text(AppStrings.cancelSubscription),
                    )
                  ],
                ),
              ),
            ),

          ],
        )
    );
  }
}