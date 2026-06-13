import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackbarHelper {
  static void show({
    required BuildContext context,
    required dynamic message,
    required Color backgroundColor,
  }) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Clear current snackbars immediately to avoid queue delay
    ScaffoldMessenger.of(context).clearSnackBars();

    final Widget contentWidget = message is Widget
        ? message
        : Text(
            message.toString(),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: contentWidget,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: screenHeight - topPadding - 90,
          left: 24,
          right: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
