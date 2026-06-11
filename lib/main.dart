import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'widgets/custom_button.dart';

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
          if (displayName.endsWith('|pending')) {
            // Force sign out immediately and return login screen
            authService.signOut();
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

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Scale factor based on standard mobile width of 375
    // Constrained so font sizes and spacing scale nicely on small/large mobile screens
    final double scaleFactor = (screenWidth < 600) 
        ? (screenWidth / 375.0).clamp(0.85, 1.15) 
        : 1.0;

    // Responsive padding and spacing calculations
    final double screenPaddingHorizontal = (screenWidth < 360 ? 12.0 : 24.0) * scaleFactor;
    final double screenPaddingVertical = (screenHeight < 600 ? 8.0 : 16.0) * scaleFactor;
    final double cardPadding = (screenWidth < 360 ? 16.0 : 32.0) * scaleFactor;
    
    // Cap form card max width at 450px for tablet/web support
    final double maxContentWidth = screenWidth < 600 ? (screenWidth - screenPaddingHorizontal * 2).clamp(280.0, 450.0) : 450.0;

    // Responsive sizes for elements inside card
    final double iconSize = (screenHeight < 600 ? 60.0 : 80.0) * scaleFactor;
    final double titleFontSize = 28.0 * scaleFactor;
    final double subtitleFontSize = 16.0 * scaleFactor;
    final double emailFontSize = 14.0 * scaleFactor;
    final double buttonHeight = (screenHeight < 600 ? 44.0 : 52.0) * scaleFactor;
    final double buttonFontSize = 16.0 * scaleFactor;

    final double spacerSmall = 12.0 * scaleFactor;
    final double spacerMedium = 24.0 * scaleFactor;
    final double spacerLarge = 40.0 * scaleFactor;

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
                          borderRadius: BorderRadius.circular(20),
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
