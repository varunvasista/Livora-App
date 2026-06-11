import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully authenticated!'),
              backgroundColor: Color(0xFF2ECC71),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          String title = 'Invalid Credentials';
          String subtitle = 'The email address or password you entered is incorrect. Please try again.';

          if (e.code == 'invalid-email') {
            title = 'Invalid Email Address';
            subtitle = 'The email address you entered is invalid. Please check the format and try again.';
          } else if (e.code == 'account-pending') {
            title = 'Account Pending';
            subtitle = 'Your account is awaiting administrator approval. Please try again later.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFE50914),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invalid Credentials',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'The email address or password you entered is incorrect. Please try again.',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              backgroundColor: Color(0xFFE50914),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address to reset your password.'),
          backgroundColor: Color(0xFFE50914),
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email.'),
            backgroundColor: const Color(0xFF2ECC71),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Failed to send password reset email.'),
            backgroundColor: const Color(0xFFE50914),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFE50914),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final double cardPaddingHorizontal = (screenWidth < 360 ? 16.0 : 24.0) * scaleFactor;
    final double cardPaddingVertical = (screenHeight < 600 ? 20.0 : 32.0) * scaleFactor;

    // Cap the form width to 450px on tablets/web as per responsiveness requirements
    final double maxContentWidth = screenWidth < 600 ? (screenWidth - screenPaddingHorizontal * 2).clamp(280.0, 450.0) : 450.0;

    // Responsive sizes for elements inside card
    final double logoSize = (screenHeight < 600 ? 48.0 : 64.0) * scaleFactor;
    final double logoToTitleSpace = (screenHeight < 600 ? 12.0 : 20.0) * scaleFactor;
    final double titleFontSize = 26.0 * scaleFactor;
    final double titleToSubtitleSpace = (screenHeight < 600 ? 6.0 : 8.0) * scaleFactor;
    final double subtitleFontSize = 14.0 * scaleFactor;
    final double subtitleToFieldsSpace = (screenHeight < 600 ? 20.0 : 36.0) * scaleFactor;
    final double fieldSpacing = (screenHeight < 600 ? 12.0 : 20.0) * scaleFactor;
    final double passwordToForgotSpace = (screenHeight < 600 ? 4.0 : 8.0) * scaleFactor;
    final double forgotPasswordFontSize = 14.0 * scaleFactor;
    final double buttonSpace = (screenHeight < 600 ? 16.0 : 28.0) * scaleFactor;
    final double buttonHeight = (screenHeight < 600 ? 44.0 : 52.0) * scaleFactor;
    final double buttonFontSize = 16.0 * scaleFactor;
    final double postButtonSpace = (screenHeight < 600 ? 16.0 : 24.0) * scaleFactor;
    final double bottomTextFontSize = 14.0 * scaleFactor;

    return Scaffold(
      backgroundColor: Colors.black, // simple clean background
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: cardPaddingHorizontal,
                          vertical: cardPaddingVertical,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A), // darkSurface
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF262626), // borderSubtle
                            width: 1.5,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 1. App Logo/Icon (Responsive)
                              Icon(
                                Icons.lock_person_outlined,
                                size: logoSize,
                                color: const Color(0xFFE50914),
                              ),
                              SizedBox(height: logoToTitleSpace),
                              
                              // 2. Heading: Welcome Back (Responsive text)
                              Text(
                                'Welcome Back',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: titleToSubtitleSpace),
                              
                              // 3. Subtitle: Sign in to continue (Responsive text)
                              Text(
                                'Sign in to continue',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFB3B3B3),
                                  fontSize: subtitleFontSize,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: subtitleToFieldsSpace),
                              
                              // 4. Email Field
                              CustomTextField(
                                label: 'Email',
                                hintText: 'name@example.com',
                                controller: _emailController,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),
                              
                              // 5. Password Field
                              CustomTextField(
                                label: 'Password',
                                hintText: '••••••••',
                                controller: _passwordController,
                                prefixIcon: Icons.lock_outlined,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFFB3B3B3),
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: passwordToForgotSpace),
                              
                              // 6. Forgot Password (right aligned, clickable)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _handleForgotPassword,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFE50914),
                                      fontWeight: FontWeight.w600,
                                      fontSize: forgotPasswordFontSize,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: buttonSpace),
                              
                              // 7. Sign In Button (Responsive)
                              CustomButton(
                                text: 'Sign In',
                                isLoading: _isLoading,
                                onPressed: _handleLogin,
                                height: buttonHeight,
                                fontSize: buttonFontSize,
                              ),
                              SizedBox(height: postButtonSpace),
                              
                              // 8. Bottom Section (Navigates to Signup Screen)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFB3B3B3),
                                      fontSize: bottomTextFontSize,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const SignupScreen(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFE50914),
                                        fontWeight: FontWeight.bold,
                                        fontSize: bottomTextFontSize,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
