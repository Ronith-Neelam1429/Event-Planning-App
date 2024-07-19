import 'package:event_planning/firebase_options.dart';
import 'package:event_planning/pages/authPages/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Clear tokens on startup
  final AadOAuth oauth = AadOAuth(Config(
    tenant: "your-tenant-id",
    clientId: "your-client-id",
    scope: "openid profile offline_access User.Read",
    redirectUri: "your-redirect-uri",
    navigatorKey: navigatorKey,
  ));
  await oauth.logout();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Event Planning',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(navigatorKey: navigatorKey),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
