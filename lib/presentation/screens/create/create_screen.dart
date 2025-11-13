import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/analytics_service.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  bool _hasAttemptedValidation = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController textController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final _analytics = AnalyticsService();

  @override
  void dispose() {
    textController.dispose();
    authorController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  /// Очищення помилок при зміні тексту
  void _onFieldChanged() {
    if (_hasAttemptedValidation) {
      setState(() {});
    }
  }

  /// Валідація тексту цитати
  String? _validateQuoteText(String? value) {
    if (!_hasAttemptedValidation) return null;

    if (value == null || value.trim().isEmpty) {
      return AppStrings.quoteEmpty;
    }
    if (value.trim().length < 10) {
      return AppStrings.quoteTextMinLength;
    }
    return null;
  }

  /// Валідація автора
  String? _validateAuthor(String? value) {
    if (!_hasAttemptedValidation) return null;

    if (value == null || value.trim().isEmpty) {
      return AppStrings.authorRequired;
    }
    if (value.trim().length < 2) {
      return AppStrings.authorMinLength;
    }
    return null;
  }

  /// Валідація тегів (опціонально)
  String? _validateTags(String? value) {
    if (!_hasAttemptedValidation) return null;

    if (value != null && value.trim().isNotEmpty) {
      final tags = value.split(',').map((tag) => tag.trim()).toList();
      if (tags.any((tag) => tag.isEmpty)) {
        return AppStrings.tagsEmptyError;
      }
    }
    return null;
  }

  Future<void> _handleSave() async {
    setState(() {
      _hasAttemptedValidation = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await _analytics.logCreateQuote(
      author: authorController.text.trim(),
      tagsCount: tagsController.text
          .split(',')
          .where((tag) => tag.trim().isNotEmpty)
          .length,
    );

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.quoteSaved)));
      Navigator.pop(context);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildForm(),
                    const SizedBox(height: 24),
                    _buildButtons(context),
                  ],
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
      AppStrings.createQuote,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        CustomTextField(
          label: AppStrings.quoteText,
          placeholder: AppStrings.quoteTextPlaceholder,
          controller: textController,
          maxLines: 4,
          validator: _validateQuoteText,
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: AppStrings.author,
          placeholder: AppStrings.authorPlaceholder,
          controller: authorController,
          validator: _validateAuthor,
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: AppStrings.tags,
          placeholder: AppStrings.tagsPlaceholder,
          controller: tagsController,
          validator: _validateTags,
          onChanged: (_) => _onFieldChanged(),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(text: AppStrings.save, onPressed: _handleSave),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: AppStrings.cancel,
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
        ),
      ],
    );
  }
}
