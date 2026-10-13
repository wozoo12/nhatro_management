import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final bool isRequired;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? suffixWidget;
  final Function(String)? onChanged;
  final String? errorText;
  final bool isCurrency;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.suffixWidget,
    this.onChanged,
    this.errorText,
    this.isCurrency = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
            ),
            if (isRequired)
              const Text(" *", style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: isCurrency ? TextInputType.number : keyboardType,
          onChanged: onChanged,
          inputFormatters: [
            if (isCurrency) ...[
              FilteringTextInputFormatter.digitsOnly,
              _CurrencyInputFormatter(),
            ],
            if (inputFormatters != null) ...inputFormatters!,
          ],
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey),
                    onPressed: onToggleVisibility,
                  )
                : suffixIcon,
            suffix: suffixWidget,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.dangerRed, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Chỉ lấy số
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedText.isEmpty) return newValue.copyWith(text: '');

    // 2. Đếm số lượng chữ số đứng trước con trỏ để giữ vị trí selection chính xác
    int cursorPosition = newValue.selection.baseOffset;
    int digitsBeforeCursor = 0;
    for (int i = 0; i < cursorPosition && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }

    // 3. Định dạng chuỗi số với dấu phân cách hàng nghìn (vi_VN)
    final formatter = NumberFormat.decimalPattern('vi_VN');
    String formattedText = formatter.format(int.parse(cleanedText));

    // 4. Tìm vị trí con trỏ mới trong chuỗi đã định dạng dựa trên số lượng chữ số đã đếm
    int newCursorOffset = 0;
    int digitCount = 0;
    while (digitCount < digitsBeforeCursor && newCursorOffset < formattedText.length) {
      if (RegExp(r'[0-9]').hasMatch(formattedText[newCursorOffset])) {
        digitCount++;
      }
      newCursorOffset++;
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }
}
