import 'package:errand_share/data/database.dart';
import 'package:errand_share/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:errand_share/component/facebook_webview.dart';

// Responsible for managing user account and session
// Login using one of several methods,
// sign up, and edit settings with firebase.
class Authenticator {
  
  // Follows Singleton pattern.
  // Only one instance exists per run.
  static final Authenticator _instance = Authenticator._internal();
  factory Authenticator() => _instance;
  Authenticator._internal(); // Private constructor

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Direct user to Google's sign in page.
  // Will create an account if one does not exist.
  Future<dynamic> signInWithGoogle() async {
    try {
      final _googleSignIn = GoogleSignIn();
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return _auth
        .signInWithCredential(credential)
        .then((auth) {
          if(auth.additionalUserInfo.isNewUser){
            return Database().createNewUser(User(uid: auth.user.uid, email: auth.user.email, isNewUser: true));
          }
          return Database().getUserById(auth.user.uid);
        }).catchError((err) {throw err;});
    } catch (error) {
      debugPrint('google auth error: ${error}');
      return '${error}';
    }
  }

  // Requires widget context to spawn a internet window.
  Future<dynamic> signInWithFacebook(BuildContext context) async {
    try{
      final clientID = '712116632854328';
      final redirectURL = 'https://errandshare-439d3.firebaseapp.com/__/auth/handler';
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FacebookWebView(
            selectedUrl: 'https://www.facebook.com/dialog/oauth?client_id=${clientID}&redirect_uri=${redirectURL}&response_type=token&scope=email,public_profile,',
          ),
        maintainState: true),
      );

      if (result == null) return null;
      final facebookAuthCred = FacebookAuthProvider.getCredential(accessToken: result);
      return _auth.signInWithCredential(facebookAuthCred)
        .then((user) async {
          if (user.additionalUserInfo.isNewUser){
            final newUser = User(
              uid: user.user.uid, 
              email: user.user.email, 
              firstName: user.additionalUserInfo.profile['first_name'],
              lastName: user.additionalUserInfo.profile['last_name'],
              isNewUser: true,
            );
            return Database().createNewUser(newUser).catchError((error){throw error;});
          }
          return Database().getUserById(user.user.uid).catchError((error){throw error;});
        }).catchError((error) {throw error;});
    } catch (e) {
      debugPrint('Facebook sign in error: ${e}');
      return '${e}';
    }
  }

  // Attempt a Sign in with email and password.
  // Encryption and verification are handled by Google.
  Future<dynamic> signInWithEmail(String email, String password) async {
    try {
      return (await _auth.signInWithEmailAndPassword(email: email, password: password)
        .then((user) => Database().getUserById(user.user.uid))
        .catchError((error) {throw Exception('${error}');}));
    } catch(ex) {
      return '${ex}';
    }
  }

  Future<void> verifyEmailAddress([FirebaseUser user]) async {
    try {
      user ??= await _auth.currentUser();
      if(user == null) return;
      return user.sendEmailVerification();
    } catch(error) {
      debugPrint('email verification error: ${error}');
      return error;
    }
  }

  Future<void> resetPassword(String email) async =>
    await _auth.sendPasswordResetEmail(email: email);

  // Sign out a logged in user.
  Future<void> signOut() {
    return _auth.signOut();
  }

  // Return logged in user or null if none exists
  Future<User> currentUser() async {
    return _auth.currentUser().then(
      (user) => (user == null) ? null : Database().getUserById(user.uid)
    );
  }

  // Create a new account and log in user.
  // Throws error on:
  //  1) weak password
  //  2) invalid email
  //  3) user already exists
  Future<dynamic> createAccountWithEmail(String email, String password) async {
    try {
    return (await _auth.createUserWithEmailAndPassword(email: email, password: password)
      .then((auth) {
        verifyEmailAddress(auth.user);
        return Database().createNewUser(User(uid: auth.user.uid, email: email, isNewUser: true));
      })
      .catchError((error) {throw Exception('${error}');}));
    } catch(error) {
      debugPrint('Account creation error: ${error}');
      return '${error}';
    }
  }
}
