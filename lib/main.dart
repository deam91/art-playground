import 'package:art/common/utils.dart';
import 'package:art/pages/atoms_sphere.dart';
import 'package:art/pages/drawing.dart';
import 'package:art/pages/rings/rings.dart';
import 'package:art/pages/perlin_field.dart';
import 'package:art/pages/perlin_sphere.dart';
import 'package:art/pages/supershapes.dart';
import 'package:art/pages/terrain/terrain.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'common/colors.dart';

void main() {
  runApp(const ProcessingApp());
  doWhenWindowReady(() {
    const initialSize = Size(1200, 650);
    appWindow.minSize = const Size(810, 450);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'Art? Playground';
    appWindow.show();
  });
}

class ProcessingApp extends StatelessWidget {
  const ProcessingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              color: Colors.white,
              fontFamily: 'SQUARE721',
              fontWeight: FontWeight.w700),
          titleMedium: TextStyle(
              color: Colors.white,
              fontFamily: 'SQUARE721',
              fontWeight: FontWeight.w700),
          titleSmall: TextStyle(
              color: Colors.white,
              fontFamily: 'SQUARE721',
              fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(
              color: Colors.white,
              fontFamily: 'SQUARE721',
              fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(
              color: Colors.white,
              fontFamily: 'SQUARE721',
              fontWeight: FontWeight.w700),
          bodySmall: TextStyle(
              color: Colors.white,
              fontFamily: 'SQUARE721',
              fontWeight: FontWeight.w700),
          labelLarge: TextStyle(
              color: Colors.white,
              fontFamily: 'SQUARE721',
              fontWeight: FontWeight.w700),
          labelMedium: TextStyle(
              color: Colors.white,
              fontFamily: 'SQUARE721',
              fontWeight: FontWeight.w700),
          labelSmall: TextStyle(
              color: Colors.white,
              fontFamily: 'SQUARE721',
              fontWeight: FontWeight.w700),
        ),
      ),
      routes: {
        '/': (_) => const LoadingPage(),
        '/home': (_) => const NavigationDrawerExample(),
      },
      initialRoute: '/',
    );
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({
    super.key,
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final Future<bool>? loading;
  Future<bool> _startLoading() async {
    return Future<bool>.delayed(const Duration(seconds: 2), () => true);
  }

  @override
  void initState() {
    super.initState();
    loading = _startLoading();
    loading?.whenComplete(
        () => Navigator.of(context).pushReplacementNamed('/home'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundEndColor,
      body: FutureBuilder(
        future: loading,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: 100,
                    child: AtomsSphere(),
                  ),
                  SizedBox(height: 20),
                  Text('PROCESSING...'),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ExampleDestination {
  const ExampleDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<ExampleDestination> destinations = <ExampleDestination>[
  ExampleDestination(
      'Rings',
      Icon(Icons.circle_outlined, size: 18, color: Colors.white),
      Icon(Icons.circle, size: 18, color: Colors.white)),
  ExampleDestination(
      'Perlin Noise',
      Icon(Icons.line_axis_rounded, size: 18, color: Colors.white),
      Icon(Icons.line_axis_rounded, size: 18, color: Colors.white)),
  ExampleDestination(
      '3D Sphere',
      Icon(Icons.looks_3_outlined, size: 18, color: Colors.white),
      Icon(
        Icons.looks_3,
        size: 18,
        color: Colors.white,
      )),
  ExampleDestination(
      'Supershapes',
      Icon(Icons.looks_3_outlined, size: 18, color: Colors.white),
      Icon(
        Icons.looks_3,
        size: 18,
        color: Colors.white,
      )),
  ExampleDestination(
      'Terrain',
      Icon(Icons.terrain_outlined, size: 18, color: Colors.white),
      Icon(
        Icons.terrain_rounded,
        size: 18,
        color: Colors.white,
      )),
  ExampleDestination(
      'Atoms Sphere',
      Icon(Icons.looks_3_outlined, size: 18, color: Colors.white),
      Icon(
        Icons.looks_3,
        size: 18,
        color: Colors.white,
      )),
  ExampleDestination(
      'Drawing',
      Icon(Icons.draw_outlined, size: 18, color: Colors.white),
      Icon(
        Icons.draw,
        size: 18,
        color: Colors.white,
      )),
];

class NavigationDrawerExample extends StatefulWidget {
  const NavigationDrawerExample({super.key});

  @override
  State<NavigationDrawerExample> createState() =>
      _NavigationDrawerExampleState();
}

class _NavigationDrawerExampleState extends State<NavigationDrawerExample> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int screenIndex = 0;
  late bool showNavigationDrawer;

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      screenIndex = selectedScreen;
    });
  }

  getWidgetByIndex() {
    if (screenIndex == 0) {
      return const Expanded(
        child: Rings(
          rings: 10,
          child: SizedBox.shrink(),
        ),
      );
    } else if (screenIndex == 1) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const PerlinField(),
          ),
        ),
      );
    } else if (screenIndex == 2) {
      return const Expanded(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: PerlinSphere(),
        ),
      );
    } else if (screenIndex == 3) {
      return const SuperShapeContainer();
    } else if (screenIndex == 4) {
      return const Expanded(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Terrain(),
        ),
      );
    } else if (screenIndex == 5) {
      return const Expanded(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: AtomsSphere(),
        ),
      );
    } else if (screenIndex == 6) {
      return const Expanded(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Drawing(),
        ),
      );
    }
    return Text('Page Index = $screenIndex');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showNavigationDrawer = MediaQuery.of(context).size.width >= 810;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundEndColor,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              children: [
                Expanded(
                  child: NavigationDrawer(
                    backgroundColor: sidebarColor,
                    surfaceTintColor: Colors.white,
                    indicatorColor: backgroundEndColor,
                    onDestinationSelected: handleScreenChanged,
                    selectedIndex: screenIndex,
                    children: <Widget>[
                      WindowTitleBarBox(
                        child: MoveWindow(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                        child: Text(
                          'Examples',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      ...destinations.map(
                        (ExampleDestination destination) {
                          return NavigationDrawerDestination(
                            label: Text(
                              destination.label,
                              style: const TextStyle(color: Colors.white),
                            ),
                            icon: destination.icon,
                            selectedIcon: destination.selectedIcon,
                          );
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => launch(
                                  'https://www.linkedin.com/in/deam-diaz/'),
                              tooltip: 'deam-diaz',
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                foregroundColor: Colors.white,
                              ),
                              icon: SvgPicture.asset(
                                'assets/linkedin.svg',
                                color: Colors.white,
                                width: 20,
                                height: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () =>
                                  launch('https://twitter.com/deamdeveloper'),
                              tooltip: '@deamdeveloper',
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                foregroundColor: Colors.white,
                              ),
                              icon: SvgPicture.asset(
                                'assets/twitter.svg',
                                color: Colors.white,
                                width: 20,
                                height: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () =>
                                  launch('https://github.com/deam91'),
                              tooltip: 'deam91',
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                foregroundColor: Colors.white,
                              ),
                              icon: SvgPicture.asset(
                                'assets/github.svg',
                                color: Colors.white,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 8,
              child: Container(
                decoration: const BoxDecoration(
                  color: backgroundEndColor,
                ),
                child: Column(
                  children: <Widget>[
                    WindowTitleBarBox(
                      child: MoveWindow(),
                    ),
                    getWidgetByIndex(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
