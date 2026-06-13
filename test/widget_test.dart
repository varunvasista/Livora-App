import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livora/screens/signup_screen.dart';
import 'package:livora/screens/login_screen.dart';
import 'package:livora/screens/organization_details_screen.dart';
import 'package:livora/screens/organization_approval_waiting_screen.dart';
import 'package:livora/widgets/custom_textfield.dart';
import 'package:livora/services/auth_service.dart';

void main() {
  setUpAll(() {
    // Avoid network requests for Google Fonts during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('ApprovalWaitingScreen renders title and messages with Next button', (WidgetTester tester) async {
    // Build the ApprovalWaitingScreen inside a MaterialApp to provide context
    await tester.pumpWidget(
      const MaterialApp(
        home: ApprovalWaitingScreen(),
      ),
    );

    // Verify "Account Created Successfully" title exists
    expect(find.text('Account Created Successfully'), findsOneWidget);

    // Verify clock icon exists
    expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);

    // Verify approval messages are present
    expect(
      find.textContaining('Your account has been created successfully'),
      findsOneWidget,
    );

    // Verify the "Next" button exists
    expect(find.text('Next'), findsOneWidget);

    // Verify the old "Return to Login" button is completely removed
    expect(find.text('Return to Login'), findsNothing);
  });

  testWidgets('LoginScreen renders Welcome title when hasLoggedInBefore is false', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    await AuthService.initPrefs();
    final authService = AuthService();
    await authService.setHasLoggedInBefore(false);

    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Sign in or create an account to get started'), findsOneWidget);
    expect(find.text('Welcome Back'), findsNothing);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('LoginScreen renders Welcome Back title when hasLoggedInBefore is true', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    await AuthService.initPrefs();
    final authService = AuthService();
    await authService.setHasLoggedInBefore(true);

    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Welcome'), findsNothing);
    expect(find.text("Don't have an account?"), findsNothing);
    expect(find.text('Sign Up'), findsNothing);
  });

  testWidgets('OrganizationDetailsScreen renders layout and form fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OrganizationDetailsScreen(),
      ),
    );

    // Verify header title and subtitle
    expect(find.text('Organization Details'), findsOneWidget);
    expect(find.text('Complete your profile to request access approval'), findsOneWidget);

    // Verify form fields are rendered by looking for their labels
    expect(find.text('Church Name *'), findsOneWidget);
    expect(find.text('Church Organizer Name *'), findsOneWidget);
    expect(find.text('Church Address *'), findsOneWidget);
    expect(find.text('Church Website (Optional)'), findsOneWidget);
    expect(find.text('Church YouTube Link *'), findsOneWidget);
    expect(find.text('Church Social Media Links (Optional)'), findsOneWidget);
    expect(find.text('Upload Church Images (Optional)'), findsOneWidget);
    expect(find.text('Upload Related Images (Optional)'), findsOneWidget);

    // Verify image picker outline buttons exist
    expect(find.text('Select Church Images'), findsOneWidget);
    expect(find.text('Select Related Images'), findsOneWidget);

    // Verify submit button exists
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('OrganizationApprovalWaitingScreen renders status layout with no buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OrganizationApprovalWaitingScreen(),
      ),
    );

    // Verify custom title
    expect(find.text('Organization Details Submitted'), findsOneWidget);

    // Verify pending icon exists
    expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);

    // Verify custom message
    expect(
      find.text('Your organization information has been submitted successfully and is currently under review by the Livora administration team.'),
      findsOneWidget,
    );

    // Verify sub message
    expect(
      find.text('You will receive access once your organization has been reviewed and approved.'),
      findsOneWidget,
    );

    // Verify no buttons exist
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('OrganizationDetailsScreen shows validation errors for empty required fields', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: OrganizationDetailsScreen(),
      ),
    );

    // Tap submit button without filling anything
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Verify validation error messages are displayed
    expect(find.text('Church Name is required'), findsOneWidget);
    expect(find.text('Organizer Name is required'), findsOneWidget);
    expect(find.text('Address is required'), findsOneWidget);
    expect(find.text('YouTube link is required'), findsOneWidget);
  });

  testWidgets('OrganizationDetailsScreen shows validation error for invalid YouTube URL', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: OrganizationDetailsScreen(),
      ),
    );

    // Enter invalid YouTube URL
    await tester.enterText(find.widgetWithText(CustomTextField, 'Church YouTube Link *'), 'invalid-url');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Verify YouTube validation error is displayed
    expect(find.text('Enter a valid YouTube link'), findsOneWidget);
  });
}
