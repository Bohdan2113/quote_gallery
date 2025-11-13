import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/analytics_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthRepository _authRepository = AuthRepository();
  final _analytics = AnalyticsService();

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    final user = _authRepository.currentUser;

    return Container(
      decoration: _buildBackgroundDecoration(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildUserInfo(user),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context),
                ],
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildBackButton(context),
        const SizedBox(width: 12),
        _buildTitle(),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEF2FF)),
        ),
        child: const Center(
          child: Icon(Icons.arrow_back, size: 20, color: AppTheme.textPrimary),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      AppStrings.profile,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildUserInfo(User? user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(user),
        const SizedBox(width: 18),
        _buildUserDetails(user),
      ],
    );
  }

  Widget _buildAvatar(User? user) {
    final name = user?.displayName ?? 'User';
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD89B), Color(0xFFFF6A88)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails(User? user) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user?.displayName ?? AppStrings.userNamePlaceholder,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            user?.email ?? AppStrings.userEmailPlaceholder,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Column(
      children: [
        if (!kIsWeb)
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: AppStrings.testCrashlytics,
              onPressed: () {
                // Тестовий код для генерації помилки в Crashlytics
                // Crashlytics не підтримується на веб-платформі
                try {
                  FirebaseCrashlytics.instance.crash();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Crashlytics не підтримується на цій платформі',
                        ),
                      ),
                    );
                  }
                }
              },
              isOutlined: true,
              color: Colors.orange,
            ),
          ),
        if (!kIsWeb) const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: AppStrings.logout,
            onPressed: () => _handleLogout(context),
            isOutlined: true,
            color: AppTheme.danger,
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    await _analytics.logLogout();
    await _authRepository.signOut();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.logoutSuccess)));
    }
  }
}
