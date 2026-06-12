import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 52.0,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final rh = ResponsiveHelper(context);
    final bool isDisabled = onPressed == null || isLoading;
    final double computedHeight = rh.space(height);
    final double computedFontSize = fontSize != null ? rh.text(fontSize!) : rh.text(16.0);
    final double computedSpinnerSize = rh.space(24.0);

    return Container(
      width: double.infinity,
      height: computedHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rh.space(12)),
        color: isDisabled ? const Color(0xFF262626) : const Color(0xFFE50914), // solid background
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(rh.space(12)),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: computedSpinnerSize,
                    height: computedSpinnerSize,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.inter(
                      color: isDisabled ? const Color(0xFF666666) : Colors.white,
                      fontSize: computedFontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
