import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../data/mock/mock_data.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginTab = true;

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    final user = MockData.mockUsers.firstWhere(
      (u) =>
          u.email.toLowerCase() == email.toLowerCase() &&
          u.password == password,
      orElse: () => MockData.mockUsers.first,
    );

    MockData.currentUser = user;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Успішний вхід')));

    Navigator.pushReplacementNamed(context, '/main');
  }

  void _handleRegister() {
    MockData.currentUser = MockData.mockUsers.first;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Реєстрація успішна')));

    Navigator.pushReplacementNamed(context, '/main');
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildTabs(),
                      const SizedBox(height: 18),
                      _buildForm(),
                    ],
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
          'QuoteGallery',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Text(
          'Збережи улюблені цитати.',
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
            text: 'Вхід',
            isActive: isLoginTab,
            onTap: () => setState(() => isLoginTab = true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabButton(
            text: 'Реєстрація',
            isActive: !isLoginTab,
            onTap: () => setState(() => isLoginTab = false),
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
          label: 'Електронна пошта',
          placeholder: 'email@example.com',
          controller: loginEmailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Пароль',
          placeholder: 'пароль',
          controller: loginPasswordController,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CustomButton(text: 'Увійти', onPressed: _handleLogin),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        CustomTextField(
          label: 'Ім\'я',
          placeholder: 'Ваше ім\'я',
          controller: registerNameController,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Електронна пошта',
          placeholder: 'email@example.com',
          controller: registerEmailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Пароль',
          placeholder: 'пароль',
          controller: registerPasswordController,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: 'Зареєструватися',
            onPressed: _handleRegister,
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
