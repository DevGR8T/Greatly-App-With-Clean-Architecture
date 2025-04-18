import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Remote data source for authentication-related operations.
class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth; // Firebase instance
  final GoogleSignIn _googleSignIn; // Google Sign-In instance

  AuthRemoteDataSource(this._firebaseAuth, this._googleSignIn);

  /// Signs in with email and password.
  Future<User?> signInWithEmail(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user; // Return the signed-in user
  }

  /// Registers a new user with email and password.
  Future<User?> registerWithEmail(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user; // Return the registered user
  }

  /// Sends a password reset email to the user.
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Retrieves the currently logged-in user.
  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser; // Return the current user
  }

  /// Sends an email verification link to the user.
  Future<void> sendEmailVerification() async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently logged in.',
      );
    }
    await currentUser.sendEmailVerification();
  }

  /// Checks if the user's email is verified.
  Future<bool> isEmailVerified() async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently logged in.',
      );
    }
    await currentUser.reload(); // Reload user to get updated verification status
    return currentUser.emailVerified;
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Signs in with Google.
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-canceled',
        message: 'Google sign-in was canceled.',
      );
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user; // Return the signed-in user
  }

  /// Registers a new user with Google.
  Future<UserCredential> registerWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-canceled',
        message: 'Google sign-in was canceled.',
      );
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Return the full UserCredential object
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Signs in with Apple.
  Future<User?> signInWithApple() async {
    final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final OAuthCredential credential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user; // Return the signed-in user
  }

  /// Registers a new user with Apple.
  Future<User?> registerWithApple() async {
    final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final OAuthCredential credential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user; // Return the registered user
  }
}