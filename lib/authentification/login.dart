import 'package:donidata/authentification/custom_textfield.dart';
import 'package:donidata/authentification/signup.dart';
import 'package:donidata/authentification/mdpforgot.dart'; 
import 'package:donidata/provider/userProvider.dart';
import 'package:donidata/screen/bottom.dart';
import 'package:donidata/services/firebase_auth.dart';
import 'package:donidata/services/toas.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Connexion avec Firebase Auth
      User? user = await _auth.signInWithEmailAndPassword(email, password);

      if (user != null) {
        // Appel à fetchUserData pour charger les données utilisateur
        await userProvider.fetchUserData();

        showToast(message: "Utilisateur connecté avec succès");

        Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyBottomNavigationBar()),
                  );
      } else {
        showToast(message: "Une erreur est survenue lors de la connexion.");
      }
    } catch (e) {
      showToast(message: "Erreur : ${e.toString()}");
    } finally {
      setState(() {
        _isSigning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[100]!, Colors.green[100]!, Colors.blue[200]!],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: screenHeight * 0.2,
              ),
              SizedBox(height: screenHeight * 0.03),
              CustomTextField(
                controller: _emailController,
                icon: Icons.email,
                hintText: 'Email',
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomTextField(
                controller: _passwordController,
                icon: Icons.lock,
                hintText: "Mot de passe",
                obscureText: true,
              ),
              // Ajout du bouton pour rediriger vers la page de mot de passe oublié
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Mdpforgot()),
                    );
                  },
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed: _isSigning ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0A1B34),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isSigning
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Se Connecter',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Vous N'avez Pas De Compte? ",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "S'inscrire",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0A1B34),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
