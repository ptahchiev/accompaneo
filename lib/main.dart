import 'package:accompaneo/models/playlists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/playlists_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'values/app_routes.dart';
import 'values/app_theme.dart';
import 'values/app_colors.dart';
import 'utils/helpers/navigation_helper.dart';
import 'utils/helpers/snackbar_helper.dart';
import 'routes.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(
      ChangeNotifierProvider(
        create: (context) => PlaylistsModel(),
        child: Accompaneo(),
      ),
    )
  );

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
    return 
        GestureDetector(
          onTap: () {
            final FocusScopeNode currentScope = FocusScope.of(context);
            if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
              currentScope.unfocus();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Accompaneo'),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Search',
                  onPressed: () {
                    NavigationHelper.pushNamed(AppRoutes.playlistSearch);
                  },
                )],
            ),
            body: IndexedStack(index: _selectedIndex, children: _pages),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: AppColors.darkerBlue,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: 
                            Text('Accompaneo', style: AppTheme.titleLarge),
                          ),
                          
                          Text('ver. 1.0',style: AppTheme.bodySmall),
                          Text('by Petar Tahchiev', style: AppTheme.bodySmall),
                        ]
                      ),
                    )
                  ),
                  ListTile(
                    title: const Text('Logout'),
                    selected: _selectedIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      //logout
                      //navigate to login screen
                      NavigationHelper.pushReplacementNamed(AppRoutes.login);                      
                    },
                  ),
                ],
              ),
            ),
            bottomNavigationBar: 
              NavigationBar(
                elevation: 0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                destinations: <NavigationDestination>[
                  NavigationDestination(
                    icon: Container(padding: EdgeInsets.symmetric(vertical: 10),child: Icon(Icons.home)),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_rounded),
                    label: 'Settings',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.headphones),
                    label: 'Playlists',
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accompaneo',
      initialRoute: AppRoutes.login,
      theme: AppTheme.themeData,
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
  State<AccompaneoApp> createState() => _AccompaneoState(selectedIndex: selectedIndex);

  const AccompaneoApp({super.key, required this.selectedIndex});
}