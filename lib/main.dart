import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'widgets/custom_button.dart';
import 'utils/responsive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using currentPlatform options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livora Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // pureBlack
        primaryColor: const Color(0xFFE50914), // livoraRed
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          onPrimary: Colors.white,
          surface: Color(0xFF0A0A0A),
          onSurface: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF000000),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          final displayName = user.displayName ?? '';
          if (displayName.endsWith('|pending') || !user.emailVerified) {
            return const LoginScreen();
          }
          return SuccessScreen(user: user);
        }

        return const LoginScreen();
      },
    );
  }
}

class SuccessScreen extends StatelessWidget {
  final User user; // firebase_auth User

  const SuccessScreen({super.key, required this.user});

  @override
  @override
  Widget build(BuildContext context) {
    final String email = user.email ?? 'No email';
    final AuthService authService = AuthService();

    final rh = ResponsiveHelper(context);

    // Responsive padding and spacing calculations
    final double screenPaddingHorizontal = rh.screenPaddingHorizontal;
    final double screenPaddingVertical = rh.screenPaddingVertical;
    final double cardPadding = rh.cardPaddingHorizontal;
    
    // Cap form card max width at 450px for tablet/web support
    final double maxContentWidth = rh.maxContentWidth;

    // Responsive sizes for elements inside card
    final double iconSize = rh.space(rh.screenHeight < 600 ? 56.0 : 72.0);
    final double titleFontSize = rh.text(24.0);
    final double subtitleFontSize = rh.text(14.0);
    final double emailFontSize = rh.text(12.0);
    final double buttonHeight = rh.screenHeight < 600 ? 44.0 : 50.0;
    final double buttonFontSize = 15.0;

    final double spacerSmall = rh.space(12.0);
    final double spacerMedium = rh.space(24.0);
    final double spacerLarge = rh.space(36.0);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // simple clean background
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
                          color: const Color(0xFF0A0A0A), // darkSurface
                          borderRadius: BorderRadius.circular(rh.space(20)),
                          border: Border.all(
                            color: const Color(0xFF262626), // borderSubtle
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Success Icon (Responsive)
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: iconSize,
                              color: const Color(0xFF2ECC71), // success green
                            ),
                            SizedBox(height: spacerMedium),
                            
                            // 2. Login Successful (Responsive text)
                            Text(
                              'Login Successful',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerSmall),
                            
                            // 3. Subtitle (Responsive text)
                            Text(
                              'Welcome back! You have successfully logged into your account.',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFB3B3B3),
                                fontSize: subtitleFontSize,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerSmall),
                            
                            // 4. User Email (Responsive text)
                            Text(
                              email,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF666666),
                                fontSize: emailFontSize,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerLarge),
                            
                            // 5. Log Out Button (Responsive)
                            CustomButton(
                              text: 'Log Out',
                              height: buttonHeight,
                              fontSize: buttonFontSize,
                              onPressed: () async {
                                await authService.signOut();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Successfully logged out!'),
                                      backgroundColor: Color(0xFFE50914),
                                    ),
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
