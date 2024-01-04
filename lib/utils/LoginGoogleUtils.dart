import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginGoogleUtils {
  static String TAG = "LoginGoogleUtils";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(clientId: '928661676759-ig1i01qvoj6u2eursgi7m62kq82q8k4j.apps.googleusercontent.com');

  Future<User?> signInWithGoogle() async {
    try {
      log("$TAG, signInWithGoogle() init...");

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      log("$TAG, signInWithGoogle() googleUser email -> ${googleSignInAccount?.email}");


      if (googleSignInAccount == null) {
        // El usuario canceló el inicio de sesión de Google
        log("$TAG, Google Sign In cancelled.");
        return null;
      }

      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      return _isCurrentSignIn(user);

      

    }  
    catch (error) {
      log("$TAG, signInWithGoogle error: $error");
      return null;
    }
  }
  
  Future<User?> _isCurrentSignIn(User? user) async {
    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User? currentUser = _auth.currentUser;
      assert (user.uid == currentUser?.uid);

      log('$TAG, signInWithGoogle succeeded: $user');

      return user;
    }
    return null;
  }
}
