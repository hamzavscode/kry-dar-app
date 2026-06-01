import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'signup_screen.dart';
import '../widgets/main_shell.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool _isLoading = false;
  String? _statusMessage;
  bool _statusIsError = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _statusIsError = true;
        _statusMessage = 'Veuillez remplir l\'e-mail et le mot de passe.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _statusIsError = false;
    });

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // 1) Check if account exists in Firestore (by email)
      final snap = await firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        setState(() {
          _statusIsError = true;
          _statusMessage = 'Compte introuvable dans la base de données.';
        });
        return;
      }

      // 2) Authenticate password first
      // Use the same trimmed email used for Firestore lookup to avoid mismatch.
      final cred = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        throw Exception('Connexion impossible. Utilisateur introuvable.');
      }

      // 3) Fetch role from Firestore after password is verified
      final data = snap.docs.first.data();
      final rawRole = data['role'];
      final role = (rawRole is String) ? rawRole.trim().toLowerCase() : null;

      if (role == null || (role != 'owner' && role != 'renter')) {
        setState(() {
          _statusIsError = true;
          _statusMessage = 'Rôle invalide pour ce compte.';
        });
        return;
      }

      // 4) Route based on role
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainShell(role: role),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusIsError = true;
        _statusMessage = e.message ?? 'Erreur de connexion.';
      });
    } catch (e) {
      setState(() {
        _statusIsError = true;
        _statusMessage = 'Erreur: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.38,
            child: Image.asset(
              'assets/images/arch_background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 80,
            left: -10,
            width: MediaQuery.of(context).size.width * 0.42,
            child: Image.asset(
              'assets/images/plants.png',
              fit: BoxFit.contain,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2010),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Adresse e-mail',
                        icon: Icons.mail_outline,
                      ),
                      const SizedBox(height: 14),
                      _buildPasswordField(),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4845A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFFB06040),
                          ),
                          child: Text(
                            _isLoading ? '...' : 'Se connecter',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_statusMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            _statusMessage!,
                            style: TextStyle(
                              color: _statusIsError
                                  ? const Color(0xFFD32F2F)
                                  : const Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          // TODO: implement forgot password.
                        },
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: Color(0xFFD4845A),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFFD4845A),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Divider(
                        height: 32,
                        color: Color(0xFFCCBBA0),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas encore inscrit ? ',
                        style: TextStyle(
                          color: Color(0xFF4A2010),
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Créez un compte',
                          style: TextStyle(
                            color: Color(0xFF3D7A8A),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF3D7A8A),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D0),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Color(0xFF4A2010), fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9A8070), fontSize: 16),
          prefixIcon: Icon(icon, color: const Color(0xFF7A6050), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D0),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Color(0xFF4A2010), fontSize: 16),

        decoration: InputDecoration(
          hintText: 'Mot de passe',
          hintStyle: const TextStyle(color: Color(0xFF9A8070), fontSize: 16),
          prefixIcon:
              const Icon(Icons.lock_outline, color: Color(0xFF7A6050), size: 22),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF4A2010),
                size: 20,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}