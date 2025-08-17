import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream controller for auth state changes
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  
  // Getter for auth state stream
  Stream<User?> get authStateChanges => _authStateController.stream;
  
  // Current user getter
  User? get currentUser => _auth.currentUser;
  
  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
  
  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  AuthService() {
    // Listen to Firebase auth state changes
    _auth.authStateChanges().listen((User? user) {
      _authStateController.add(user);
    });
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        return AuthResult.failure(errorMessage: 'Email and password are required');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure(errorMessage: 'Please enter a valid email address');
      }

      if (password.length < 6) {
        return AuthResult.failure(errorMessage: 'Password must be at least 6 characters');
      }

      // Attempt sign in
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Update last sign in time
        await _updateLastSignIn(credential.user!.uid);
        
        // Get user data
        final userData = await _getUserData(credential.user!.uid);
        
        // Save remember me preference
        if (rememberMe) {
          await _saveRememberMePreference(true);
        }

        return AuthResult.success(
          user: userData,
          token: await credential.user!.getIdToken(),
        );
      } else {
        return AuthResult.failure(errorMessage: 'Sign in failed');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(errorMessage: _getFirebaseErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(errorMessage: 'An unexpected error occurred');
    }
  }

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    bool acceptTerms = false,
    bool acceptPrivacyPolicy = false,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
        return AuthResult.failure(errorMessage: 'All fields are required');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.failure(errorMessage: 'Please enter a valid email address');
      }

      if (password.length < 6) {
        return AuthResult.failure(errorMessage: 'Password must be at least 6 characters');
      }

      if (!acceptTerms || !acceptPrivacyPolicy) {
        return AuthResult.failure(errorMessage: 'You must accept terms and privacy policy');
      }

      // Check if email already exists
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        return AuthResult.failure(errorMessage: 'An account with this email already exists');
      }

      // Create user account
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);
        
        // Create user profile in Firestore
        final userData = await _createUserProfile(
          credential.user!,
          displayName,
        );

        // Send email verification
        await credential.user!.sendEmailVerification();

        return AuthResult.success(
          user: userData,
          token: await credential.user!.getIdToken(),
        );
      } else {
        return AuthResult.failure(errorMessage: 'Account creation failed');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(errorMessage: _getFirebaseErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(errorMessage: 'An unexpected error occurred');
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger Google sign in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return AuthResult.failure(errorMessage: 'Google sign in was cancelled');
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Create new user profile
          await _createUserProfile(
            userCredential.user!,
            userCredential.user!.displayName ?? 'User',
          );
        } else {
          // Update last sign in
          await _updateLastSignIn(userCredential.user!.uid);
        }

        // Get user data
        final userData = await _getUserData(userCredential.user!.uid);

        return AuthResult.success(
          user: userData,
          token: await userCredential.user!.getIdToken(),
        );
      } else {
        return AuthResult.failure(errorMessage: 'Google sign in failed');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(errorMessage: _getFirebaseErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(errorMessage: 'Google sign in failed');
    }
  }

  /// Sign in with Apple
  Future<AuthResult> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        return AuthResult.failure(errorMessage: 'Apple Sign In is not available on this device');
      }

      // Request Apple Sign In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create Firebase credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
      
      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Create new user profile
          final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
          await _createUserProfile(
            userCredential.user!,
            displayName.isNotEmpty ? displayName : 'User',
          );
        } else {
          // Update last sign in
          await _updateLastSignIn(userCredential.user!.uid);
        }

        // Get user data
        final userData = await _getUserData(userCredential.user!.uid);

        return AuthResult.success(
          user: userData,
          token: await userCredential.user!.getIdToken(),
        );
      } else {
        return AuthResult.failure(errorMessage: 'Apple sign in failed');
      }
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(errorMessage: _getFirebaseErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(errorMessage: 'Apple sign in failed');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      // Clear remember me preference
      await _saveRememberMePreference(false);

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      if (email.isEmpty || !_isValidEmail(email)) {
        return AuthResult.failure(errorMessage: 'Please enter a valid email address');
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(errorMessage: _getFirebaseErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure(errorMessage: 'Password reset failed');
    }
  }

  /// Update user profile
  Future<AuthResult> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);

      return AuthResult.success();
    } catch (e) {
      return AuthResult.failure(errorMessage: 'Profile update failed');
    }
  }

  /// Delete user account
  Future<AuthResult> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult.failure(errorMessage: 'No user signed in');
      }

      // Delete user data from Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete user authentication
      await user.delete();

      return AuthResult.success();
    } catch (e) {
      return AuthResult.failure(errorMessage: 'Account deletion failed');
    }
  }

  /// Get user data from Firestore
  Future<User> _getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return User.fromJson(doc.data()!);
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      // Return default user if data fetch fails
      return User(
        id: userId,
        email: _auth.currentUser?.email ?? '',
        displayName: _auth.currentUser?.displayName,
        photoURL: _auth.currentUser?.photoURL,
        createdAt: _auth.currentUser?.metadata.creationTime ?? DateTime.now(),
        lastSignInAt: _auth.currentUser?.metadata.lastSignInTime ?? DateTime.now(),
        emailVerified: _auth.currentUser?.emailVerified ?? false,
        pets: [],
        profile: UserProfile(
          firstName: _auth.currentUser?.displayName?.split(' ').first,
          lastName: _auth.currentUser?.displayName?.split(' ').last,
          interests: [],
        ),
        preferences: UserPreferences(
          notifications: NotificationSettings(
            pushEnabled: true,
            emailEnabled: false,
            smsEnabled: false,
            enabledTypes: ['health_reminders', 'vet_appointments'],
            quietHours: TimeRange(
              start: const TimeOfDay(hour: 22, minute: 0),
              end: const TimeOfDay(hour: 7, minute: 0),
            ),
          ),
          privacy: PrivacySettings(
            profilePublic: false,
            petsPublic: false,
            healthDataShared: false,
            trustedContacts: [],
            analyticsEnabled: true,
          ),
          aiPreferences: AIPreferences(
            preferredModel: 'gpt-5',
            enabledFeatures: ['emotion_recognition', 'health_analysis'],
            autoAnalysis: true,
            personalizedRecommendations: true,
            modelSettings: {},
          ),
          theme: ThemeSettings(
            themeMode: 'system',
            colorScheme: 'default',
            useSystemTheme: true,
          ),
          language: LanguageSettings(
            language: 'en',
            region: 'US',
            autoDetect: true,
          ),
        ),
        subscription: SubscriptionInfo(
          plan: 'free',
          startDate: DateTime.now(),
          isActive: false,
          features: ['basic_tracking', 'limited_ai_insights'],
          monthlyPrice: 0.0,
          billingCycle: 'monthly',
        ),
      );
    }
  }

  /// Create user profile in Firestore
  Future<User> _createUserProfile(FirebaseUser firebaseUser, String displayName) async {
    final user = User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: displayName,
      photoURL: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
      emailVerified: firebaseUser.emailVerified,
      pets: [],
      profile: UserProfile(
        firstName: displayName.split(' ').first,
        lastName: displayName.split(' ').length > 1 ? displayName.split(' ').last : null,
        interests: [],
      ),
      preferences: UserPreferences(
        notifications: NotificationSettings(
          pushEnabled: true,
          emailEnabled: false,
          smsEnabled: false,
          enabledTypes: ['health_reminders', 'vet_appointments'],
          quietHours: TimeRange(
            start: const TimeOfDay(hour: 22, minute: 0),
            end: const TimeOfDay(hour: 7, minute: 0),
          ),
        ),
        privacy: PrivacySettings(
          profilePublic: false,
          petsPublic: false,
          healthDataShared: false,
          trustedContacts: [],
          analyticsEnabled: true,
        ),
        aiPreferences: AIPreferences(
          preferredModel: 'gpt-5',
          enabledFeatures: ['emotion_recognition', 'health_analysis'],
          autoAnalysis: true,
          personalizedRecommendations: true,
          modelSettings: {},
        ),
        theme: ThemeSettings(
          themeMode: 'system',
          colorScheme: 'default',
          useSystemTheme: true,
        ),
        language: LanguageSettings(
          language: 'en',
          region: 'US',
          autoDetect: true,
        ),
      ),
      subscription: SubscriptionInfo(
        plan: 'free',
        startDate: DateTime.now(),
        isActive: false,
        features: ['basic_tracking', 'limited_ai_insights'],
        monthlyPrice: 0.0,
        billingCycle: 'monthly',
      ),
    );

    // Save to Firestore
    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(user.toJson());

    return user;
  }

  /// Update last sign in time
  Future<void> _updateLastSignIn(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'lastSignInAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating last sign in: $e');
    }
  }

  /// Save remember me preference
  Future<void> _saveRememberMePreference(bool rememberMe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', rememberMe);
    } catch (e) {
      print('Error saving remember me preference: $e');
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Get Firebase error message
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

// Extension to add FirebaseUser compatibility
extension FirebaseUserExtension on FirebaseUser {
  FirebaseUser get asFirebaseUser => this;
}