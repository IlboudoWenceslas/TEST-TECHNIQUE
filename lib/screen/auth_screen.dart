
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final ApiService _api = ApiService();
  bool isLogin = true;
  bool submitting = false;
  String errorMessage = '';

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  Future<void> onSubmit() async {
    setState(() { submitting = true; errorMessage = ''; });
    try {
      String token;
      if (isLogin) {
        token = await _api.login(_emailCtrl.text, _passwordCtrl.text);
      } else {
        token = await _api.register_user(
          _firstNameCtrl.text,
          _lastNameCtrl.text,
          _emailCtrl.text,
          _passwordCtrl.text,
        );
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { errorMessage = 'Identifiants incorrects.'; submitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(isLogin ? 'Connexion' : 'Inscription'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              if (!isLogin) ...[
                TextField(controller: _firstNameCtrl, decoration: _deco('Prénom')),
                const SizedBox(height: 12),
                TextField(controller: _lastNameCtrl, decoration: _deco('Nom')),
                const SizedBox(height: 12),
              ],
              TextField(controller: _emailCtrl, decoration: _deco('Email'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              TextField(controller: _passwordCtrl, decoration: _deco('Mot de passe'), obscureText: true),
              const SizedBox(height: 16),
              if (errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Text(errorMessage, style: TextStyle(color: Colors.red[700])),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitting ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(submitting ? 'Chargement...' : (isLogin ? 'Se connecter' : "S'inscrire")),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() { isLogin = !isLogin; errorMessage = ''; }),
                child: Text(isLogin ? "Pas de compte ? S'inscrire" : 'Déjà un compte ? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}