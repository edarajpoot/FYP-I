import 'package:flutter/material.dart';
import 'package:login/database_service.dart';
import 'package:login/screens/keyword.dart';
import 'package:login/screens/login.dart';
import 'package:login/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignUpScreen(), // Start with the SignUpScreen
  ));
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final dbService = DatabaseService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false; // Loading state

  Future<void> signup() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // **Validations**
    if (name.isEmpty || email.isEmpty || password.length < 6) {
      showErrorDialog("Enter a valid name, email & password (6+ characters).");
      return;
    }

    // **Check if name contains only alphabets**
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(name)) {
      showErrorDialog("Name should only contain alphabets.");
      return;
    }

    setState(() => _isLoading = true); // Show loading

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await Future.delayed(const Duration(seconds: 2));
      await FirebaseAuth.instance.currentUser?.reload();

      final user = AppUser(
        name: name,
        email: email,
        password: password,
      );

      await dbService.create(user, userCredential.user!.uid);

      // **Send email verification**
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        showInfoDialog(
          "A verification email has been sent. Please verify before logging in.",
          false,
        );

        checkEmailVerification(); // Start checking verification status
        //await FirebaseAuth.instance.signOut();
        return;

      } else {
        navigateToKeyword(); // Directly go to login if already verified
      }
    } catch (e) {
      showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false); // Hide loading
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  Future<void> showInfoDialog(String message, bool navigate) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Attention"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (navigate) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LogInScreen()),
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}


  void navigateToKeyword() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SetKeywordScreen()),
    );
  }

  Future<void> resendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      showInfoDialog("Verification email resent. Check your inbox.", false);
    }
  }

void checkEmailVerification() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print("User is NULL. Cannot check verification.");
    return;
  }

  for (int i = 0; i < 10; i++) { // 10 baar check karega (30 sec)
    await Future.delayed(const Duration(seconds: 3));
    await FirebaseAuth.instance.currentUser?.reload(); 
    user = FirebaseAuth.instance.currentUser;

    //print("Checking email verification: ${user?.emailVerified}");

    if (user != null && user.emailVerified) {
      print("Email Verified!");
      navigateToKeyword();
      return;
    }
  }
  print("Verification timeout. User must verify manually.");
}



  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.setLanguageCode("en");

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(37, 66, 43, 1)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset('assets/images/signup.png', width: 150, height: 150),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromRGBO(37, 66, 43, 1)),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'Create new Account!',
                    style: TextStyle(fontSize: 14, color: Color.fromRGBO(37, 66, 43, 0.8)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 370,
                    height: 50,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await signup();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(37, 66, 43, 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account ? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LogInScreen()));
                        },
                        child: const Text(
                          "Log In",
                          style: TextStyle(color: Color.fromRGBO(37, 66, 43, 1), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      await resendVerificationEmail();
                    },
                    child: const Text("Resend Verification Email", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class AppUser {
  final String name;
  final String email;
  final String password;

  AppUser({required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {"name": name, "email": email, "password": password};
  }
}
