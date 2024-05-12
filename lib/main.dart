import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:here_sdk/core.dart';
// import 'package:here_sdk/core.engine.dart';
// import 'package:here_sdk/core.errors.dart';
import 'package:pothole_detection_realtime/Views/homeScreen.dart';
import 'package:pothole_detection_realtime/Services/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // _initializeHERESDK();
  runApp(const MyApp());
}

// void _initializeHERESDK() async {
//   // Needs to be called before accessing SDKOptions to load necessary libraries.
//   SdkContext.init(IsolateOrigin.main);

//   // Set your credentials for the HERE SDK.
//   String accessKeyId = "w42zrR8ZO4kt57GAr6rP-A";
//   String accessKeySecret = "-c_nDe95eKxhUsT6kB4_lUH22dJyFG1ZRnExmQTpWMZEmR6k4FMn3pKZnuBQPprP0T7IKCSqd01zLTSzprjvMg";
//   SDKOptions sdkOptions = SDKOptions.withAccessKeySecret(accessKeyId, accessKeySecret);

//   try {
//     await SDKNativeEngine.makeSharedInstance(sdkOptions);
//   } on InstantiationException {
//     throw Exception("Failed to initialize the HERE SDK.");
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

// Firebase Analytics ADDED but not used yet
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
