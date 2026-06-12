import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of User auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Register with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String accountType,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name with status=pending suffix
      await credential.user?.updateDisplayName('$fullName|$accountType|pending');
      
      // Send verification email
      await credential.user?.sendEmailVerification();
      
      // Print/log variables for reference in demo/CTO review
      // In production, this can write to Firestore or assign Custom Claims
      debugPrint('Firebase Auth Signup Successful: Full Name: $fullName, Email: $email, Phone: $phone, Account Type: $accountType, Status: pending');
      
      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected registration error occurred: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await credential.user!.reload();
        final updatedUser = _auth.currentUser;
        if (updatedUser != null && !updatedUser.emailVerified) {
          // Optionally resend verification email on block
          try {
            await updatedUser.sendEmailVerification();
          } catch (e) {
            // Ignore/log rate-limiting or other email sending errors to avoid blocking the redirect
            debugPrint('Failed to optionally send verification email: $e');
          }
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'Your email is not verified. Please verify your email address to continue.',
          );
        }
      }

      if (credential.user != null) {
        final displayName = credential.user?.displayName ?? '';
        final parts = displayName.split('|');
        String fullName = parts.isNotEmpty ? parts[0] : 'User';
        String accountType = 'user';
        String status = 'active';

        if (parts.length == 3) {
          accountType = parts[1];
          status = parts[2];
        } else if (parts.length == 2) {
          accountType = 'user';
          status = parts[1];
        }

        if (accountType == 'organization' && status == 'pending') {
          await _auth.signOut();
          throw FirebaseAuthException(
            code: 'account-pending',
            message: 'Your account is awaiting administrator approval. Please try again later.',
          );
        }

        // For user accounts, if status is pending, automatically activate it
        if (accountType == 'user' && status == 'pending') {
          await credential.user!.updateDisplayName('$fullName|user|active');
        }
      }
      
      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected sign-in error occurred: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
