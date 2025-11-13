import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/analytics_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginTab = true;
  bool isLoading = false;
  bool _hasAttemptedValidation = false;

  final _formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();
  final _analytics = AnalyticsService();

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController registerConfirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerConfirmPasswordController.dispose();
    super.dispose();
  }

  /// Очищення помилок форми при зміні вкладки
  void _clearFormErrors() {
    _formKey.currentState?.reset();
    _hasAttemptedValidation = false;
    setState(() {});
  }

  /// Очищення помилок при зміні тексту в полі
  void _onFieldChanged() {
    if (_hasAttemptedValidation) {
      setState(() {});
    }
  }

  /// Валідація email
  String? _validateEmail(String? value) {
    if (!_hasAttemptedValidation) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return AppStrings.emailRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (!_hasAttemptedValidation) return null;

    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordMinLength;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_hasAttemptedValidation) return null;

    if (value == null || value.isEmpty) {
      return AppStrings.confirmPasswordRequired;
    }
    if (value != registerPasswordController.text) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }

  String? _validateName(String? value) {
    if (!_hasAttemptedValidation) return null;

    if (value == null || value.trim().isEmpty) {
      return AppStrings.nameRequired;
    }
    if (value.trim().length < 2) {
      return AppStrings.nameMinLength;
    }
    return null;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _hasAttemptedValidation = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authRepository.signIn(
        email: loginEmailController.text,
        password: loginPasswordController.text,
      );

      await _analytics.logLogin(method: 'email');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.loginSuccess)));
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? AppStrings.errorUnknown),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } catch (e) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.log('Login error: $e');
        FirebaseCrashlytics.instance.recordError(e, null, fatal: false);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.errorUnknown),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    setState(() {
      _hasAttemptedValidation = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authRepository.signUp(
        email: registerEmailController.text,
        password: registerPasswordController.text,
      );

      await _authRepository.updateProfile(
        displayName: registerNameController.text.trim(),
      );

      await _analytics.logSignUp(method: 'email');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.registerSuccess)),
        );
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? AppStrings.errorUnknown),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } catch (e) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.log('Register error: $e');
        FirebaseCrashlytics.instance.recordError(e, null, fatal: false);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.errorUnknown),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: _buildBackgroundDecoration(),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildTabs(),
                        const SizedBox(height: 18),
                        _buildForm(),
                        if (isLoading) ...[
                          const SizedBox(height: 16),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF8FAFC), AppTheme.background],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [_buildLogo(), const SizedBox(width: 12), _buildTitle()],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, Color(0xFF7B85FF)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'QG',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.appTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Text(
          AppStrings.appSubtitle,
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            text: AppStrings.login,
            isActive: isLoginTab,
            onTap: () {
              setState(() {
                isLoginTab = true;
                _clearFormErrors();
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabButton(
            text: AppStrings.register,
            isActive: !isLoginTab,
            onTap: () {
              setState(() {
                isLoginTab = false;
                _clearFormErrors();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return isLoginTab ? _buildLoginForm() : _buildRegisterForm();
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        CustomTextField(
          label: AppStrings.email,
          placeholder: AppStrings.emailPlaceholder,
          controller: loginEmailController,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: AppStrings.password,
          placeholder: AppStrings.passwordPlaceholder,
          controller: loginPasswordController,
          obscureText: true,
          showPasswordToggle: true,
          validator: _validatePassword,
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: AppStrings.loginButton,
            onPressed: isLoading ? () {} : () => _handleLogin(),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        CustomTextField(
          label: AppStrings.name,
          placeholder: AppStrings.namePlaceholder,
          controller: registerNameController,
          validator: _validateName,
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: AppStrings.email,
          placeholder: AppStrings.emailPlaceholder,
          controller: registerEmailController,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: AppStrings.password,
          placeholder: AppStrings.passwordPlaceholder,
          controller: registerPasswordController,
          obscureText: true,
          showPasswordToggle: true,
          validator: _validatePassword,
          onChanged: (_) {
            _onFieldChanged();
            // Перевіряємо також поле повтору пароля
            if (registerConfirmPasswordController.text.isNotEmpty) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: AppStrings.confirmPassword,
          placeholder: AppStrings.passwordPlaceholder,
          controller: registerConfirmPasswordController,
          obscureText: true,
          showPasswordToggle: true,
          validator: _validateConfirmPassword,
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: AppStrings.registerButton,
            onPressed: isLoading ? () {} : () => _handleRegister(),
            isPrimary: false,
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0x1F5B6CFF), Color(0x0F5B6CFF)],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? const Color(0x1F5B6CFF) : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isActive ? AppTheme.primary : AppTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
