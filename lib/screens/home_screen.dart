import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../utils/responsive_helper.dart';
import '../utils/snackbar_helper.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

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
    final double iconSize = rh.space(rh.screenHeight < 600 ? 56.0 : 72.0);
    final double titleFontSize = rh.text(24.0);
    final double subtitleFontSize = rh.text(14.0);
    final double infoFontSize = rh.text(13.0);
    final double buttonHeight = rh.screenHeight < 600 ? 44.0 : 50.0;
    final double buttonFontSize = 15.0;

    final double spacerSmall = rh.space(12.0);
    final double spacerMedium = rh.space(24.0);
    final double spacerLarge = rh.space(36.0);

    // Parse User Profile
    final displayName = user.displayName ?? '';
    final parts = displayName.split('|');
    String fullName = parts.isNotEmpty ? parts[0] : 'User';
    String rawAccountType = 'user';
    
    if (parts.length == 3) {
      rawAccountType = parts[1];
    } else if (parts.length == 2) {
      // Old format: fullName|status, assume 'user' by default for backward compatibility
      rawAccountType = 'user';
    }
    
    String accountTypeDisplay = rawAccountType.toUpperCase();
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.black,
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
                          color: darkSurface,
                          borderRadius: BorderRadius.circular(rh.space(20)),
                          border: Border.all(
                            color: borderDark,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x80000000),
                              blurRadius: rh.space(15),
                              offset: Offset(0, rh.space(8)),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.dashboard_customize_outlined,
                              size: iconSize,
                              color: primaryRed,
                            ),
                            SizedBox(height: spacerMedium),
                            Text(
                              'Welcome to Livora',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerSmall),
                            Text(
                              'Hello, $fullName!',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: subtitleFontSize,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerSmall),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: rh.space(16),
                                vertical: rh.space(10),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161616),
                                borderRadius: BorderRadius.circular(rh.space(12)),
                                border: Border.all(
                                  color: borderDark,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Account Type',
                                    style: GoogleFonts.inter(
                                      color: textLight,
                                      fontSize: infoFontSize,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: rh.space(8),
                                      vertical: rh.space(4),
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryRed.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(rh.space(6)),
                                    ),
                                    child: Text(
                                      accountTypeDisplay,
                                      style: GoogleFonts.inter(
                                        color: primaryRed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: rh.text(11.0),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: spacerLarge),
                            CustomButton(
                              text: 'Log Out',
                              height: buttonHeight,
                              fontSize: buttonFontSize,
                              onPressed: () async {
                                await authService.signOut();
                                if (context.mounted) {
                                  SnackbarHelper.show(
                                    context: context,
                                    message: 'Successfully logged out!',
                                    backgroundColor: const Color(0xFFE50914),
                                  );
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
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
