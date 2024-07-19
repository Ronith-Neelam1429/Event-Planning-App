import 'dart:convert';
import 'package:event_planning/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:event_planning/auth/auth_services.dart';
import 'package:event_planning/auth/firebase_auth.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import 'package:google_sign_in/google_sign_in.dart'; // Add this import

class LoginPage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  LoginPage({required this.navigatorKey});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Config? _config;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Authentication _auth = Authentication();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final configString = await rootBundle.loadString('assets/auth_config.json');
    final configJson = jsonDecode(configString);

    setState(() {
      _config = Config(
        tenant: configJson['authorities'][0]['audience']['tenant_id'],
        clientId: configJson['client_id'],
        scope: "openid profile offline_access User.Read",
        redirectUri: configJson['redirect_uri'],
        navigatorKey: widget.navigatorKey,
      );
    });
  }

  void _showError(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> azureSignInApi(bool redirect) async {
    if (_config == null) {
      _showError("Configuration not loaded");
      return;
    }

    final AadOAuth oauth = AadOAuth(_config!);
    _config!.webUseRedirect = redirect;
    final result = await oauth.login();
    result.fold(
      (l) => _showError("Microsoft Authentication Failed!"),
      (r) async {
        if (r.accessToken != null) {
          final userDetails =
              await AuthServices.fetchAzureUserDetails(r.accessToken!);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                  userDetails: userDetails, navigatorKey: widget.navigatorKey),
            ),
          );
        } else {
          _showError("Access token is null!");
        }
      },
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final userCredential = await _auth.signIn(
        _emailController.text,
        _passwordController.text,
      );
      // Navigate to profile page or home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userDetails: {
              'displayName': userCredential.user?.displayName ?? 'User',
              'email': userCredential.user?.email ?? '',
            },
            navigatorKey: widget.navigatorKey,
          ),
        ),
      );
    } catch (e) {
      _showError("Failed to sign in: ${e.toString()}");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      // Navigate to profile page or home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userDetails: {
              'displayName': userCredential.user?.displayName ?? 'User',
              'email': userCredential.user?.email ?? '',
            },
            navigatorKey: widget.navigatorKey,
          ),
        ),
      );
    } catch (e) {
      _showError("Failed to sign in with Google: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signInWithEmailAndPassword,
              child: Text("Sign In"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => azureSignInApi(true),
              child: Text("Sign In with Microsoft"),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Text("Sign In with Google"),
            ),
          ],
        ),
      ),
    );
  }
}
