import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    authorController.dispose();
    tagsController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // Заглушка для збереження
    if (textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Цитата порожня'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Цитату збережено (заглушка)')),
    );

    Navigator.pop(context);
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
      'Створити цитату',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        CustomTextField(
          label: 'Текст цитати',
          placeholder: 'Введи цитату...',
          controller: textController,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Автор',
          placeholder: 'Ім\'я автора',
          controller: authorController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Теги (через коми)',
          placeholder: 'motivation,life,poetry',
          controller: tagsController,
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(text: 'Зберегти', onPressed: _handleSave),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Відмінити',
            onPressed: () => Navigator.pop(context),
            isPrimary: false,
          ),
        ),
      ],
    );
  }
}
