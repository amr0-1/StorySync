import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtrack/core/theme/app_colors.dart';
import 'package:mtrack/core/theme/app_dimensions.dart';
import 'package:mtrack/core/theme/app_text_styles.dart';

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
    return Scaffold(
      backgroundColor: AppColors.inkVoid,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Logo container with manga-panel styling
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.inkPanel,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(
              color: AppColors.inkBorder,
              width: AppDimensions.borderMedium,
            ),
          ),
          child: Stack(
            children: [
              // Inner border (manga panel style)
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.goldSpark.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                ),
              ),
              // App icon
              const Center(
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 44,
                  color: AppColors.goldLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space16),

        // App name
        Text(
          'MTrack',
          style: AppTextStyles.displayLarge.copyWith(
            color: AppColors.goldLight,
          ),
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
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'your@email.com',
        prefixIcon: Icon(
          Icons.alternate_email_rounded,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: 'password',
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.textHint,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textHint,
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _handleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldSpark,
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
    return TextButton(
      onPressed: _handleGuestMode,
      child: Text(
        'Continue without account',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
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
