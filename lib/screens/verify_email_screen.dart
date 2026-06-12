import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../utils/responsive_helper.dart';
import 'signup_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final bool isFromLogin;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.isFromLogin = false,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService();
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerificationStatus() async {
    setState(() => _isChecking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        // Get the updated user state
        final updatedUser = FirebaseAuth.instance.currentUser;
        if (updatedUser != null && updatedUser.emailVerified) {
          // Sign out explicitly so they remain signed out while awaiting admin approval
          await _authService.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email verified successfully!'),
                backgroundColor: Color(0xFF2ECC71),
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const ApprovalWaitingScreen(),
              ),
            );
          }
          return;
        }
      }
      
      // If not verified
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification is still pending. Please check your inbox.'),
            backgroundColor: Color(0xFFE50914),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking status: ${e.toString()}'),
            backgroundColor: const Color(0xFFE50914),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email resent! Please check your inbox.'),
              backgroundColor: Color(0xFF2ECC71),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: No active user session found.'),
              backgroundColor: Color(0xFFE50914),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend: ${e.toString()}'),
            backgroundColor: const Color(0xFFE50914),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFE50914);
    const Color darkSurface = Color(0xFF0A0A0A);
    const Color borderDark = Color(0xFF262626);
    const Color textLight = Color(0xFFB3B3B3);

    final rh = ResponsiveHelper(context);

    // Responsive padding and spacing calculations
    final double screenPaddingHorizontal = rh.screenPaddingHorizontal;
    final double screenPaddingVertical = rh.screenPaddingVertical;
    final double cardPadding = rh.cardPaddingHorizontal;
    final double maxContentWidth = rh.maxContentWidth;

    // Responsive sizes for elements inside card
    final double iconSize = rh.space(rh.screenHeight < 600 ? 44.0 : 56.0);
    final double titleFontSize = rh.text(24.0);
    final double subtitleFontSize = rh.text(14.0);
    final double additionalMsgFontSize = rh.text(12.0);
    final double buttonHeight = rh.screenHeight < 600 ? 44.0 : 50.0;
    final double buttonFontSize = 15.0;

    final double spacerSmall = rh.space(12.0);
    final double spacerMedium = rh.space(24.0);
    final double spacerLarge = rh.space(36.0);

    return Scaffold(
      backgroundColor: Colors.black, // black background
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenPaddingHorizontal,
                    vertical: screenPaddingVertical,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxContentWidth,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: darkSurface, // Card Background: Very Dark Gray
                          borderRadius: BorderRadius.circular(rh.space(20)),
                          border: Border.all(
                            color: borderDark, // Borders: Dark Gray
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x80000000), // Subtle shadow
                              blurRadius: rh.space(15),
                              offset: Offset(0, rh.space(8)),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Mail icon inside subtle dark circular background
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(spacerSmall),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF161616),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.mail_outline_rounded,
                                  size: iconSize,
                                  color: primaryRed,
                                ),
                              ),
                            ),
                            SizedBox(height: spacerMedium),

                            // Title
                            Text(
                              'Verify Your Email',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerSmall),

                            // Registered Email Subtitle
                            Text(
                              'A verification email has been sent to:',
                              style: GoogleFonts.inter(
                                color: textLight,
                                fontSize: subtitleFontSize,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: rh.space(6)),
                            Text(
                              widget.email,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerSmall),

                            // Description
                            Text(
                              'Please check your inbox (and spam folder) and click the verification link to activate your account.',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF666666),
                                fontSize: additionalMsgFontSize,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerLarge),

                            // Check Verification Status Button
                            CustomButton(
                              text: 'Check Verification Status',
                              isLoading: _isChecking,
                              onPressed: _checkVerificationStatus,
                              height: buttonHeight,
                              fontSize: buttonFontSize,
                            ),
                            SizedBox(height: spacerSmall),

                            // Resend Verification Email Button
                            TextButton(
                              onPressed: _isResending ? null : _resendVerificationEmail,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: rh.space(12)),
                              ),
                              child: _isResending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(primaryRed),
                                      ),
                                    )
                                  : Text(
                                      'Resend Verification Email',
                                      style: GoogleFonts.inter(
                                        color: primaryRed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: rh.text(14.0),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
