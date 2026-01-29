import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'package:found_food/core/theme/app_typography.dart';
import 'package:found_food/shared/widgets/buttons/custom_buttons.dart';

class SignUpEmailScreen extends StatefulWidget {
  const SignUpEmailScreen({super.key});

  @override
  State<SignUpEmailScreen> createState() => _SignUpEmailScreenState();
}

class _SignUpEmailScreenState extends State<SignUpEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Inscription par Email',
          style: AppTypography.h3.copyWith(fontSize: 20, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Prêt à découvrir ?',
                  style: AppTypography.h2.copyWith(fontSize: 28, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remplissez vos informations pour commencer l\'aventure.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 40),
                
                // Nom complet
                _buildFieldTitle('Nom complet'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Ex: Jean Dupont',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez entrer votre nom';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Email
                _buildFieldTitle('Email'),
                _buildTextField(
                  controller: _emailController,
                  hint: 'votre@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
                    if (!value.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Mot de passe
                _buildFieldTitle('Mot de passe'),
                _buildTextField(
                  controller: _passwordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                    if (value.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Confirmer le mot de passe
                _buildFieldTitle('Confirmer le mot de passe'),
                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                
                // Bouton d'inscription
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return PrimaryButton(
                      text: 'Créer mon compte',
                      isLoading: auth.isLoading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await auth.signUp(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            _nameController.text.trim(),
                          );
                          
                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Compte créé ! Veuillez vérifier votre email.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(auth.error ?? 'Erreur d\'inscription'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      backgroundColor: AppColors.primaryOrange,
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Login redirect
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/signin'),
                    child: RichText(
                      text: TextSpan(
                        text: 'Déjà un compte ? ',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.bodyMedium,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
