import 'dart:convert';
import 'package:event_planning/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:event_planning/auth/auth_services.dart';
import 'package:event_planning/auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterPage extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  RegisterPage({required this.navigatorKey});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

  Future<void> azureSignUpApi(bool redirect) async {
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
          Navigator.pushReplacement(
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

  Future<void> _signUpWithEmailAndPassword() async {
    try {
      final userCredential = await _auth.signUp(
        _emailController.text,
        _passwordController.text,
      );
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
      _showError("Failed to sign up: ${e.toString()}");
    }
  }

  Future<void> _signUpWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If the user cancels the sign-in flow, googleUser will be null
      if (googleUser == null) return;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in (or sign up) to Firebase with the Google credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // This is a new user, you might want to do additional setup here
        print("New user created with Google Sign-In");
      } else {
        print("Existing user signed in with Google");
      }

      // Navigate to the ProfilePage
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
      _showError("Failed to sign up with Google: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Page")),
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
              onPressed: _signUpWithEmailAndPassword,
              child: Text("Sign Up"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => azureSignUpApi(true),
              child: Text("Sign Up with Microsoft"),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _signUpWithGoogle,
              child: Text("Sign Up with Google"),
            ),
          ],
        ),
      ),
    );
  }
}
