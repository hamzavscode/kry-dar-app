import 'package:flutter/material.dart';

import '../services/firestore_signup_service.dart';

class SignupScreen extends StatefulWidget {
  final String role;

  const SignupScreen({super.key, this.role = 'owner'});


  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _firestoreService = FirestoreSignupService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2010),
                  ),
                ),
                const SizedBox(height: 36),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Nom complet',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _phoneController,
                        hint: 'Numéro de téléphone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Adresse e-mail',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      _buildPasswordField(),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final fullName = _nameController.text.trim();
                                  final phoneNumber = _phoneController.text.trim();
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text;

                                  setState(() {
                                    _statusMessage = null;
                                    _statusIsError = false;
                                  });

                                  if (fullName.isEmpty || phoneNumber.isEmpty) {
                                    setState(() {
                                      _statusIsError = true;
                                      _statusMessage =
                                          'Veuillez remplir le nom complet et le numéro.';
                                    });
                                    return;
                                  }

                                  if (email.isEmpty || password.isEmpty) {
                                    setState(() {
                                      _statusIsError = true;
                                      _statusMessage =
                                          'Veuillez remplir l’e-mail et le mot de passe.';
                                    });
                                    return;
                                  }

                                  setState(() => _isLoading = true);

                                  try {
                                    // DEBUG: prevents silent hang; visible in console
                                    // ignore: avoid_print
                                    print('Signup pressed. role=${widget.role}, email=$email');
                                    final exists = await _firestoreService
                                        .emailExists(email: email);

                                    if (exists) {
                                      setState(() {
                                        _statusIsError = true;
                                        _statusMessage =
                                            "Cet e-mail existe déjà.";
                                      });
                                      return;
                                    }

                                    // Role: default required by your request.
                                    await _firestoreService.createUser(
                                      fullName: fullName,
                                      phoneNumber: phoneNumber,
                                      email: email,
                                      password: password,
                                      role: widget.role,
                                    );

                                    setState(() {
                                      _statusIsError = false;
                                      _statusMessage =
                                          'Compte créé avec succès !';
                                    });

                                    // Redirect to login directly.
                                    if (!mounted) return;
                                    Navigator.of(context)
                                        .pushReplacementNamed('/login');
                                  } catch (e) {
                                    setState(() {
                                      _statusIsError = true;
                                      _statusMessage =
                                          'Erreur: ${e.toString()}';
                                    });
                                  } finally {
                                    if (mounted) setState(() => _isLoading = false);
                                  }
                                },
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
                            _isLoading ? '...' : "S'inscrire",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_statusMessage != null)
                        Text(
                          _statusMessage!,
                          style: TextStyle(
                            color: _statusIsError
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
                        'Déjà inscrit ? ',
                        style: TextStyle(
                          color: Color(0xFF4A2010),
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: const Text(
                          'Connectez-vous',
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
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
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
          hintText: 'Choisir un mot de passe',
          hintStyle: const TextStyle(color: Color(0xFF9A8070), fontSize: 16),
          prefixIcon:
              const Icon(Icons.lock_outline, color: Color(0xFF7A6050), size: 22),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF7A6050),
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}


