import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';

class CostumField extends StatefulWidget {
  const CostumField({
    super.key,
    this.isPassword = false,
    this.width,
    this.alignment,
    this.labelText,
    this.controller,
    this.errorText,
    this.onChanged,
    this.keyboardType,
    this.readOnly = false,
    this.enabled = true,
  });

  final bool isPassword;
  final double? width;
  final Alignment? alignment;
  final String? labelText;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool enabled;

  @override
  State<CostumField> createState() => _CostumFieldState();
}

class _CostumFieldState extends State<CostumField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: widget.alignment ?? Alignment.center,
            child: SizedBox(
              width: widget.width,
              child: TextField(
                controller: widget.controller,
                obscureText: widget.isPassword ? _obscureText : false,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                readOnly: widget.readOnly,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                  errorText: hasError ? widget.errorText : null,
                  suffixIcon: widget.isPassword
                      ? IconButton(
                          onPressed: () {
                            if (mounted)
                              setState(() => _obscureText = !_obscureText);
                          },
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20.sp,
                          ),
                        )
                      : null,
                  border: _buildBorder(
                    hasError ? AppColors.error : AppColors.borderLight,
                  ),
                  enabledBorder: _buildBorder(
                    hasError ? AppColors.error : AppColors.borderLight,
                  ),
                  focusedBorder: _buildBorder(
                    hasError ? AppColors.error : AppColors.accentBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: color, width: width.w),
    );
  }
}
