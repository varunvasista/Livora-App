import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../utils/responsive_helper.dart';
import 'signup_screen.dart';
import 'verify_email_screen.dart';

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
          if (e.code == 'email-not-verified') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => VerifyEmailScreen(
                  email: _emailController.text.trim(),
                  isFromLogin: true,
                ),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your email is not verified. Please verify your email address to continue.'),
                backgroundColor: Color(0xFFE50914),
              ),
            );
            return;
          }

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
    final rh = ResponsiveHelper(context);

    // Responsive padding and spacing calculations
    final double screenPaddingHorizontal = rh.screenPaddingHorizontal;
    final double screenPaddingVertical = rh.screenPaddingVertical;
    final double cardPaddingHorizontal = rh.cardPaddingHorizontal;
    final double cardPaddingVertical = rh.cardPaddingVertical;
    final double maxContentWidth = rh.maxContentWidth;

    // Responsive sizes for elements inside card
    final double logoSize = rh.space(rh.screenHeight < 600 ? 40.0 : 48.0);
    final double logoToTitleSpace = rh.space(rh.screenHeight < 600 ? 10.0 : 14.0);
    final double titleFontSize = rh.text(22.0);
    final double titleToSubtitleSpace = rh.space(6.0);
    final double subtitleFontSize = rh.text(12.0);
    final double subtitleToFieldsSpace = rh.space(rh.screenHeight < 600 ? 16.0 : 24.0);
    final double fieldSpacing = rh.space(rh.screenHeight < 600 ? 10.0 : 14.0);
    final double passwordToForgotSpace = rh.space(4.0);
    final double forgotPasswordFontSize = rh.text(12.0);
    final double buttonSpace = rh.space(rh.screenHeight < 600 ? 12.0 : 20.0);
    // Button height and fontSize are scaled dynamically inside CustomButton, so we pass base values
    final double buttonHeight = rh.screenHeight < 600 ? 40.0 : 44.0;
    final double buttonFontSize = 14.5;
    final double postButtonSpace = rh.space(rh.screenHeight < 600 ? 12.0 : 16.0);
    final double bottomTextFontSize = rh.text(12.0);

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
                          borderRadius: BorderRadius.circular(rh.space(16)),
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
                                    padding: EdgeInsets.symmetric(horizontal: rh.space(4), vertical: rh.space(4)),
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
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: rh.space(4),
                                runSpacing: rh.space(4),
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
                                      padding: EdgeInsets.symmetric(horizontal: rh.space(4), vertical: rh.space(4)),
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
