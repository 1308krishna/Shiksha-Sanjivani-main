import 'package:classinsight/bindings.dart';
import 'package:classinsight/firebase_options.dart';
import 'package:classinsight/routes/mainRoutes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  InitialBinding().dependencies();
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await GetStorage.init();
  } catch (e) {}
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  bool isTeacherLogged = false;
  bool isParentLogged = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    final storage = GetStorage();
    isTeacherLogged = storage.read('isTeacherLogged') ?? false;
    isParentLogged = storage.read('isParentLogged') ?? false;
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: InitialBinding(),
      title: 'Class Insight',
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        useMaterial3: true,
      ),
      initialRoute: _getInitialLocation(user),
      getPages: MainRoutes.routes,
    );
  }

  String _getInitialLocation(User? user) {
    if (user != null) {
      if (isTeacherLogged) {
        return '/TeacherDashboard';
      } else {
        return '/AdminHome';
      }
    } else if (isParentLogged) {
      return '/ParentDashboard';
    } else {
      return '/onBoarding';
    }
  }
}
