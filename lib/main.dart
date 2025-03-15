import 'package:accompaneo/models/playlists.dart';
import 'package:accompaneo/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'pages/home_page.dart';
import 'pages/playlists_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'routes.dart';
import 'utils/helpers/navigation_helper.dart';
import 'utils/helpers/snackbar_helper.dart';
import 'values/app_colors.dart';
import 'values/app_routes.dart';
import 'values/app_theme.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(
        ChangeNotifierProvider(
          create: (context) => PlaylistsModel(),
          child: Accompaneo(token: prefs.getString('token')),
        ),
      ));

  FlutterNativeSplash.remove();
}

class _AccompaneoState extends State<AccompaneoApp> {
  int selectedIndex;

  int _selectedIndex = 0;

  _AccompaneoState({required this.selectedIndex});

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    ProfilePage(),
    SettingsPage(),
    PlaylistsPage()
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = selectedIndex;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final FocusScopeNode currentScope = FocusScope.of(context);
        if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
          currentScope.unfocus();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.accompaneo),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search',
                onPressed: () {
                  NavigationHelper.pushNamed(AppRoutes.playlistSearch);
                },
              )
            ],
          ),
          body: IndexedStack(index: _selectedIndex, children: _pages),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                    decoration: BoxDecoration(
                      color: AppColors.darkerBlue,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(AppLocalizations.of(context)!.accompaneo, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white)),
                            ),
                            Text('v. 1.0', style: Theme.of(context).textTheme.bodySmall),
                            Text(AppLocalizations.of(context)!.byPetarTahchiev,
                                style: Theme.of(context).textTheme.bodySmall),
                          ]),
                    )),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.logout),
                  selected: _selectedIndex == 0,
                  onTap: () {
                    ApiService.logout().then((v) {
                      Navigator.pop(context);
                      //logout
                      //navigate to login screen
                      NavigationHelper.pushReplacementNamed(AppRoutes.login);
                    });
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            elevation: 0,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.home),
                label: AppLocalizations.of(context)!.home,
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: AppLocalizations.of(context)!.profile,
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_rounded),
                label: AppLocalizations.of(context)!.settings,
              ),
              NavigationDestination(
                icon: Icon(Icons.headphones),
                label: AppLocalizations.of(context)!.playlists,
              )
            ],
          )),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class Accompaneo extends StatelessWidget {
  final String? token;

  const Accompaneo({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    bool hasValidToken = token != null;

    return MaterialApp(
      title: 'Accompaneo',
      locale: Provider.of<PlaylistsModel>(context, listen:true).getSettings().sessionLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,    
      initialRoute: hasValidToken ? AppRoutes.home : AppRoutes.login,
      theme: AppTheme.theme(Provider.of<PlaylistsModel>(context, listen:true).getThemeMode().name),
      themeMode: Provider.of<PlaylistsModel>(context, listen:false).getThemeMode(),
      navigatorKey: NavigationHelper.key,
      scaffoldMessengerKey: SnackbarHelper.key,
      onGenerateRoute: Routes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

class AccompaneoApp extends StatefulWidget {
  final int selectedIndex;

  @override
  State<AccompaneoApp> createState() =>
      _AccompaneoState(selectedIndex: selectedIndex);

  const AccompaneoApp({super.key, required this.selectedIndex});
}
