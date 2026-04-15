import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_colors.dart';

/// App Button
/// Generic, reusable button widget with multiple variants
/// Supports: primary, secondary, outlined, text, and icon buttons
class AppButton extends StatelessWidget {
  /// Button text
  final String? text;

  /// Button icon (optional)
  final IconData? icon;

  /// Icon position relative to text
  final IconPosition iconPosition;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button variant/style
  final ButtonVariant variant;

  /// Button size
  final ButtonSize size;

  /// Custom width (optional)
  final double? width;

  /// Custom height (optional)
  final double? height;

  /// Whether button is in loading state
  final bool isLoading;

  /// Whether button is enabled
  final bool isEnabled;

  /// Custom background color (optional, overrides variant color)
  final Color? backgroundColor;

  /// Custom text color (optional, overrides variant color)
  final Color? textColor;

  /// Border radius
  final double? borderRadius;

  /// Custom padding
  final EdgeInsets? padding;

  /// Font size
  final double? fontSize;

  /// Font weight
  final FontWeight? fontWeight;

  const AppButton({
    super.key,
    this.text,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.width,
    this.height,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.fontSize,
    this.fontWeight,
  }) : assert(
         text != null || icon != null,
         'Either text or icon must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final isDisabled = !isEnabled || isLoading || onPressed == null;

    // Get size-specific values
    final sizeConfig = _getSizeConfig();

    // Get variant-specific colors
    final colors = _getVariantColors(isDisabled);

    // Build button content
    Widget content = _buildContent(sizeConfig);

    // Apply loading state
    if (isLoading) {
      content = SizedBox(
        width: sizeConfig.iconSize,
        height: sizeConfig.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(colors.textColor),
        ),
      );
    }

    // Build button widget based on variant
    Widget button;
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        button = _buildFilledButton(
          content: content,
          colors: colors,
          sizeConfig: sizeConfig,
          isDisabled: isDisabled,
        );
        break;
      case ButtonVariant.outlined:
        button = _buildOutlinedButton(
          content: content,
          colors: colors,
          sizeConfig: sizeConfig,
          isDisabled: isDisabled,
        );
        break;
      case ButtonVariant.text:
        button = _buildTextButton(
          content: content,
          colors: colors,
          sizeConfig: sizeConfig,
          isDisabled: isDisabled,
        );
        break;
      case ButtonVariant.icon:
        button = _buildIconButton(
          content: content,
          colors: colors,
          sizeConfig: sizeConfig,
          isDisabled: isDisabled,
        );
        break;
    }

    // Apply width/height constraints
    if (width != null || height != null) {
      button = SizedBox(
        width: width,
        height: height ?? sizeConfig.height,
        child: button,
      );
    }

    return button;
  }

  Widget _buildContent(_SizeConfig sizeConfig) {
    final hasText = text != null && text!.isNotEmpty;
    final hasIcon = icon != null;

    if (!hasText && hasIcon) {
      // Icon only
      return Icon(icon, size: sizeConfig.iconSize, color: textColor);
    }

    if (hasText && !hasIcon) {
      // Text only
      return Text(
        text!,
        style: TextStyle(
          fontSize: fontSize ?? sizeConfig.fontSize,
          fontWeight: fontWeight ?? sizeConfig.fontWeight,
          color: textColor,
        ),
      );
    }

    // Both text and icon
    final iconWidget = Icon(icon, size: sizeConfig.iconSize, color: textColor);

    final textWidget = Text(
      text!,
      style: TextStyle(
        fontSize: fontSize ?? sizeConfig.fontSize,
        fontWeight: fontWeight ?? sizeConfig.fontWeight,
        color: textColor,
      ),
    );

    if (iconPosition == IconPosition.left) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          SizedBox(width: 8.w),
          textWidget,
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          textWidget,
          SizedBox(width: 8.w),
          iconWidget,
        ],
      );
    }
  }

  Widget _buildFilledButton({
    required Widget content,
    required _ButtonColors colors,
    required _SizeConfig sizeConfig,
    required bool isDisabled,
  }) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? colors.backgroundColor,
        foregroundColor: textColor ?? colors.textColor,
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: sizeConfig.horizontalPadding,
              vertical: sizeConfig.verticalPadding,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? sizeConfig.borderRadius,
          ),
        ),
        elevation: variant == ButtonVariant.primary ? 2 : 0,
        disabledBackgroundColor: colors.disabledBackgroundColor,
        disabledForegroundColor: colors.disabledTextColor,
      ),
      child: content,
    );
  }

  Widget _buildOutlinedButton({
    required Widget content,
    required _ButtonColors colors,
    required _SizeConfig sizeConfig,
    required bool isDisabled,
  }) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? colors.textColor,
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: sizeConfig.horizontalPadding,
              vertical: sizeConfig.verticalPadding,
            ),
        side: BorderSide(
          color: backgroundColor ?? colors.borderColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? sizeConfig.borderRadius,
          ),
        ),
        disabledForegroundColor: colors.disabledTextColor,
      ),
      child: content,
    );
  }

  Widget _buildTextButton({
    required Widget content,
    required _ButtonColors colors,
    required _SizeConfig sizeConfig,
    required bool isDisabled,
  }) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? colors.textColor,
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: sizeConfig.horizontalPadding,
              vertical: sizeConfig.verticalPadding,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? sizeConfig.borderRadius,
          ),
        ),
        disabledForegroundColor: colors.disabledTextColor,
      ),
      child: content,
    );
  }

  Widget _buildIconButton({
    required Widget content,
    required _ButtonColors colors,
    required _SizeConfig sizeConfig,
    required bool isDisabled,
  }) {
    return IconButton(
      onPressed: isDisabled ? null : onPressed,
      icon: content,
      color: textColor ?? colors.textColor,
      disabledColor: colors.disabledTextColor,
      padding: padding ?? EdgeInsets.all(sizeConfig.horizontalPadding),
      iconSize: sizeConfig.iconSize,
    );
  }

  _SizeConfig _getSizeConfig() {
    switch (size) {
      case ButtonSize.small:
        return _SizeConfig(
          height: 36.h,
          horizontalPadding: 16.w,
          verticalPadding: 8.h,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          iconSize: 18.sp,
          borderRadius: 8.r,
        );
      case ButtonSize.medium:
        return _SizeConfig(
          height: 48.h,
          horizontalPadding: 24.w,
          verticalPadding: 12.h,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          iconSize: 20.sp,
          borderRadius: 12.r,
        );
      case ButtonSize.large:
        return _SizeConfig(
          height: 56.h,
          horizontalPadding: 32.w,
          verticalPadding: 16.h,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          iconSize: 24.sp,
          borderRadius: 16.r,
        );
    }
  }

  _ButtonColors _getVariantColors(bool isDisabled) {
    if (isDisabled) {
      return _ButtonColors(
        backgroundColor: AppColors.grey300,
        textColor: AppColors.grey600,
        borderColor: AppColors.grey300,
        disabledBackgroundColor: AppColors.grey300,
        disabledTextColor: AppColors.grey600,
        disabledBorderColor: AppColors.grey300,
      );
    }

    switch (variant) {
      case ButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: backgroundColor ?? AppColors.primaryNavy,
          textColor: textColor ?? Colors.white,
          borderColor: AppColors.primaryNavy,
          disabledBackgroundColor: AppColors.grey300,
          disabledTextColor: AppColors.grey600,
          disabledBorderColor: AppColors.grey300,
        );
      case ButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor: backgroundColor ?? AppColors.primaryBlue,
          textColor: textColor ?? Colors.white,
          borderColor: AppColors.primaryBlue,
          disabledBackgroundColor: AppColors.grey300,
          disabledTextColor: AppColors.grey600,
          disabledBorderColor: AppColors.grey300,
        );
      case ButtonVariant.outlined:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: textColor ?? AppColors.primaryNavy,
          borderColor: backgroundColor ?? AppColors.primaryNavy,
          disabledBackgroundColor: Colors.transparent,
          disabledTextColor: AppColors.grey600,
          disabledBorderColor: AppColors.grey300,
        );
      case ButtonVariant.text:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: textColor ?? AppColors.primaryNavy,
          borderColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledTextColor: AppColors.grey600,
          disabledBorderColor: Colors.transparent,
        );
      case ButtonVariant.icon:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: textColor ?? AppColors.primaryNavy,
          borderColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledTextColor: AppColors.grey600,
          disabledBorderColor: Colors.transparent,
        );
    }
  }
}

/// Button variant types
enum ButtonVariant { primary, secondary, outlined, text, icon }

/// Button size types
enum ButtonSize { small, medium, large }

/// Icon position relative to text
enum IconPosition { left, right }

/// Internal size configuration
class _SizeConfig {
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final FontWeight fontWeight;
  final double iconSize;
  final double borderRadius;

  _SizeConfig({
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.fontWeight,
    required this.iconSize,
    required this.borderRadius,
  });
}

/// Internal color configuration
class _ButtonColors {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color disabledBackgroundColor;
  final Color disabledTextColor;
  final Color disabledBorderColor;

  _ButtonColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.disabledBackgroundColor,
    required this.disabledTextColor,
    required this.disabledBorderColor,
  });
}
