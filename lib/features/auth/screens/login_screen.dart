import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storysync/core/theme/app_colors.dart';
import 'package:storysync/core/theme/app_dimensions.dart';
import 'package:storysync/core/theme/app_text_styles.dart';
import 'package:storysync/shared/widgets/app_icon.dart';

/// Login screen with premium Void Ink styling
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    return Scaffold(
      backgroundColor: colors.inkVoid,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              // Logo section
              _buildLogo(),
              const SizedBox(height: AppDimensions.space48),

              // Form fields
              _buildEmailField(),
              const SizedBox(height: AppDimensions.space16),
              _buildPasswordField(),
              const SizedBox(height: AppDimensions.space24),

              // Sign in button
              _buildSignInButton(),
              const SizedBox(height: AppDimensions.space16),

              // Continue without account
              _buildGuestButton(),

              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    return Column(
      children: [
        // Premium app icon with shadow and rounded corners
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            boxShadow: [
              BoxShadow(
                color: colors.goldSpark.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const AppIcon.large(),
        ),
        const SizedBox(height: AppDimensions.space16),

        // App name
        Text(
          'StorySync',
          style: AppTextStyles.displayLarge.copyWith(color: colors.goldLight),
        ),
        const SizedBox(height: AppDimensions.space8),

        // Subtitle
        Text(
          'Track every chapter. Miss nothing.',
          style: AppTextStyles.monoSmall,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'your@email.com',
        prefixIcon: Icon(Icons.alternate_email_rounded, color: colors.textHint),
      ),
    );
  }

  Widget _buildPasswordField() {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: 'password',
        prefixIcon: Icon(Icons.lock_outline_rounded, color: colors.textHint),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: colors.textHint,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.goldSpark,
          foregroundColor: const Color(0xFF1A0F00),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
        ),
        child: Text(
          'Sign In',
          style: AppTextStyles.titleMedium.copyWith(
            color: const Color(0xFF1A0F00),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestButton() {
    final colors = Theme.of(context).extension<VoidInkColors>()!;
    return TextButton(
      onPressed: _handleGuestMode,
      child: Text(
        'Continue without account',
        style: AppTextStyles.bodyMedium.copyWith(color: colors.textHint),
      ),
    );
  }

  void _handleSignIn() {
    // TODO: Implement actual authentication
    // For now, navigate to the main app
    context.go('/library');
  }

  void _handleGuestMode() {
    // TODO: Set guest mode flag in shared preferences if needed
    context.go('/library');
  }
}
