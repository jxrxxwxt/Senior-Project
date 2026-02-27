import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isObscure = true;

  void _handleLogin() async {
    DialogUtils.showLoading(context);
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_usernameCtrl.text, _passwordCtrl.text);
      if(mounted) {
        DialogUtils.hideLoading(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
      }
    } catch (e) {
      if(mounted) {
        DialogUtils.hideLoading(context);
        DialogUtils.showError(context, "Invalid username or password");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.people_alt_rounded, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Welcome Back", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              const Text("Sign in to continue to Detection App", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey)),
              const SizedBox(height: 40),
              
              const Text("Username", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: _usernameCtrl, decoration: const InputDecoration(hintText: "Enter your username", prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 16),
              
              const Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordCtrl,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _handleLogin, child: const Text("Sign In")),
              
              const SizedBox(height: 24),
              Row(children: [const Expanded(child: Divider()), const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("or")), const Expanded(child: Divider())]),
              const SizedBox(height: 24),
              
              OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                icon: const Icon(Icons.person_add),
                label: const Text("Create New Account"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  foregroundColor: AppColors.textDark
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                   Provider.of<AuthProvider>(context, listen: false).loginAsGuest();
                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                },
                child: const Text("Continue as Guest", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}