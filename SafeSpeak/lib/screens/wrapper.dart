import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/screens/home.dart';
import 'package:login/screens/splash.dart';
import 'package:login/database_service.dart';
import 'package:login/model/usermodel.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen(); // Initial loading state
          }

          if (snapshot.hasData) {
            User? user = snapshot.data;
            if (user == null) return const SplashScreen();

            return FutureBuilder<UserModel?>(
              future: DatabaseService().getUserData(user.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }

                if (userSnapshot.hasData && userSnapshot.data != null) {
                  return HomePage(user: userSnapshot.data!);
                } else {
                  return const SplashScreen();
                }
              },
            );
          } else {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}
