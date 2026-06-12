import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/auth_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../utils/responsive_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  String _completePhoneNumber = '';
  bool _obscurePassword = true;
  // ignore: prefer_final_fields
  String _accountType = 'user'; // 'user' or 'organization'
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          phone: _completePhoneNumber.isNotEmpty ? _completePhoneNumber : null,
          accountType: _accountType,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account successfully created!'),
              backgroundColor: Color(0xFF2ECC71),
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ApprovalWaitingScreen(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          String errorMessage = 'Registration failed';
          if (e.code == 'email-already-in-use') {
            errorMessage = 'An account already exists for this email.';
          } else if (e.code == 'weak-password') {
            errorMessage = 'The password provided is too weak.';
          } else if (e.code == 'invalid-email') {
            errorMessage = 'Invalid email address.';
          } else if (e.message != null) {
            errorMessage = e.message!;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
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
  }

  @override
  @override
  Widget build(BuildContext context) {
    final rh = ResponsiveHelper(context);

    // Responsive padding and spacing calculations
    final double screenPaddingHorizontal = rh.screenPaddingHorizontal;
    final double screenPaddingVertical = rh.screenPaddingVertical;
    final double cardPaddingHorizontal = rh.cardPaddingHorizontal;
    final double cardPaddingVertical = rh.cardPaddingVertical;
    final double maxContentWidth = rh.maxContentWidth;

    // Spacing heights scaled responsively
    final double headerTitleFontSize = rh.text(22.0);
    final double headerSubtitleFontSize = rh.text(12.0);
    final double headerSpacing = rh.space(4.0);
    final double headerToFieldsSpacing = rh.space(14.0);
    final double fieldSpacing = rh.space(8.0);
    final double passwordToSelectionSpacing = rh.space(10.0);
    final double selectionLabelBottomPadding = rh.space(5.0);
    final double selectionToButtonSpacing = rh.space(14.0);
    // Button height and fontSize are scaled dynamically inside CustomButton, so we pass base values
    final double buttonHeight = rh.screenHeight < 600 ? 44.0 : 50.0;
    final double buttonFontSize = 15.0;
    final double buttonToSignInSpacing = rh.space(8.0);
    final double bottomTextFontSize = rh.text(13.0);
    final double fieldVerticalPadding = 12.0; // custom text field scales it

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // simple clean background
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
                          borderRadius: BorderRadius.circular(16),
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
                              // 1. Create Account & Subtitle
                              Text(
                                'Create Account',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: headerTitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: headerSpacing),
                              Text(
                                'Join the community today',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFB3B3B3),
                                  fontSize: headerSubtitleFontSize,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: headerToFieldsSpacing),

                              // 2. Full Name
                              CustomTextField(
                                label: 'Full Name',
                                hintText: 'John Doe',
                                controller: _fullNameController,
                                prefixIcon: Icons.person_outline,
                                verticalPadding: fieldVerticalPadding,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Full name is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),

                              // 3. Email Address
                              CustomTextField(
                                label: 'Email Address',
                                hintText: 'name@example.com',
                                controller: _emailController,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                verticalPadding: fieldVerticalPadding,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email address is required';
                                  }
                                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: fieldSpacing),

                              // 4. Phone Number (Optional)
                              Padding(
                                padding: EdgeInsets.only(left: 4, bottom: selectionLabelBottomPadding),
                                child: Text(
                                  'Phone Number (Optional)',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFB3B3B3),
                                    fontWeight: FontWeight.w600,
                                    fontSize: bottomTextFontSize,
                                  ),
                                ),
                              ),
                              IntlPhoneField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  hintText: 'Phone Number',
                                  hintStyle: GoogleFonts.inter(
                                    color: const Color(0xFF666666),
                                    fontSize: 15,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF0A0A0A),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: fieldVerticalPadding),
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF262626)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF262626)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE50914),
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE50914),
                                      width: 1,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE50914),
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: GoogleFonts.inter(
                                    color: const Color(0xFFE50914),
                                    fontSize: 12,
                                  ),
                                ),
                                initialCountryCode: 'US',
                                onChanged: (phone) {
                                  _completePhoneNumber = phone.completeNumber;
                                },
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                dropdownTextStyle: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                dropdownIcon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFFB3B3B3),
                                ),
                              ),
                              SizedBox(height: fieldSpacing),

                              // 5. Password
                              CustomTextField(
                                label: 'Password',
                                hintText: '••••••••',
                                controller: _passwordController,
                                prefixIcon: Icons.lock_outlined,
                                obscureText: _obscurePassword,
                                verticalPadding: fieldVerticalPadding,
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
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: passwordToSelectionSpacing),

                              // 6. User Type Selection
                              Padding(
                                padding: EdgeInsets.only(left: 4, bottom: selectionLabelBottomPadding),
                                child: Text(
                                  'I want to join as:',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFB3B3B3),
                                    fontWeight: FontWeight.w600,
                                    fontSize: bottomTextFontSize,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _AccountTypeCard(
                                      title: 'User',
                                      icon: Icons.person_rounded,
                                      isSelected: _accountType == 'user',
                                      onTap: () => setState(() => _accountType = 'user'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _AccountTypeCard(
                                      title: 'Organization',
                                      icon: Icons.business_rounded,
                                      isSelected: _accountType == 'organization',
                                      onTap: () => setState(() => _accountType = 'organization'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: selectionToButtonSpacing),

                              // 7. Create Account Button
                              CustomButton(
                                text: 'Create Account',
                                isLoading: _isLoading,
                                onPressed: _handleSignup,
                                height: buttonHeight,
                                fontSize: buttonFontSize,
                              ),
                              SizedBox(height: buttonToSignInSpacing),
                              
                              // Navigate to Signin
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFB3B3B3),
                                      fontSize: bottomTextFontSize,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Sign In',
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

class _AccountTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rh = ResponsiveHelper(context);

    final double verticalPadding = rh.space(10.0);
    final double iconSize = rh.space(22.0);
    final double spacing = rh.space(4.0);
    final double fontSize = rh.text(12.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A), // darkSurface
            border: Border.all(
              color: isSelected ? const Color(0xFFE50914) : const Color(0xFF262626),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFE50914) : const Color(0xFFB3B3B3),
                size: iconSize,
              ),
              SizedBox(height: spacing),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : const Color(0xFFB3B3B3),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApprovalWaitingScreen extends StatelessWidget {
  const ApprovalWaitingScreen({super.key});

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
    // Button scales internally
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
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: borderDark, // Borders: Dark Gray
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x80000000), // Subtle shadow
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Red clock icon inside subtle dark circular background
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(spacerSmall),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF161616), // subtle dark circular background
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.access_time_rounded, // Red pending approval / clock icon
                                  size: iconSize,
                                  color: primaryRed,
                                ),
                              ),
                            ),
                            SizedBox(height: spacerMedium),
                            
                            // Title
                            Text(
                              'Account Created Successfully',
                              style: GoogleFonts.outfit(
                                color: Colors.white, // Headings: White
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerSmall),
                            
                            // Subtitle
                            Text(
                              'Your account has been submitted successfully and is currently awaiting administrator approval.',
                              style: GoogleFonts.inter(
                                color: textLight, // Body Text: Light Gray
                                fontSize: subtitleFontSize,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerSmall),
                            
                            // Additional Message
                            Text(
                              'You will be able to sign in once your account has been reviewed and approved by an administrator.\n\nPlease wait for confirmation before attempting to log in.',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF666666), // Medium Gray/Darker text
                                fontSize: additionalMsgFontSize,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacerLarge),
                            
                            // Button: Return to Login (styled in solid red)
                            CustomButton(
                              text: 'Return to Login',
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              height: buttonHeight,
                              fontSize: buttonFontSize,
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
