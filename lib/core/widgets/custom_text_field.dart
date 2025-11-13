import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool showPasswordToggle;

  const CustomTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.showPasswordToggle = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  final _fieldKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);

    // Оновлюємо стан при кожному введеному символі
    setState(() {
      // Очищаємо помилку при зміні тексту
      _fieldKey.currentState?.didChange(value);
      _fieldKey.currentState?.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0B1220),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: _fieldKey,
          controller: widget.controller,
          obscureText: widget.showPasswordToggle
              ? _obscureText
              : widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          validator: widget.validator,
          onChanged: _handleChanged,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            errorMaxLines: 2,
            suffixIcon: widget.showPasswordToggle
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
