import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';

class OrganizationApprovalWaitingScreen extends StatelessWidget {
  const OrganizationApprovalWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFE50914);
    const Color darkSurface = Color(0xFF0A0A0A);
    const Color borderDark = Color(0xFF262626);
    const Color textLight = Color(0xFFB3B3B3);

    final rh = ResponsiveHelper(context);

    final double screenPaddingHorizontal = rh.screenPaddingHorizontal;
    final double screenPaddingVertical = rh.screenPaddingVertical;
    final double cardPadding = rh.cardPaddingHorizontal;
    final double maxContentWidth = rh.maxContentWidth;

    final double iconSize = rh.space(rh.screenHeight < 600 ? 44.0 : 56.0);
    final double titleFontSize = rh.text(24.0);
    final double subtitleFontSize = rh.text(14.0);
    final double additionalMsgFontSize = rh.text(12.0);

    final double spacerSmall = rh.space(12.0);
    final double spacerMedium = rh.space(24.0);

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
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(spacerSmall),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF161616),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.hourglass_top_rounded, // Pending icon
                                  size: iconSize,
                                  color: primaryRed,
                                ),
                              ),
                            ),
                            SizedBox(height: spacerMedium),
                            
                            Text(
                              'Organization Details Submitted',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerSmall),
                            
                            Text(
                              'Your organization information has been submitted successfully and is currently under review by the Livora administration team.',
                              style: GoogleFonts.inter(
                                color: textLight,
                                fontSize: subtitleFontSize,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerSmall),
                            
                            Text(
                              'You will receive access once your organization has been reviewed and approved.',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF666666),
                                fontSize: additionalMsgFontSize,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
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
