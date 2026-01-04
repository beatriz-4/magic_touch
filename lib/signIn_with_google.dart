import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. MUST use the Web Client ID here for Android to show the popup
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '746994458144-2r1nbs6stu7p6e37bsqrcb40q2o3bcrm.apps.googleusercontent.com',
  );

  Future<User?> signInWithGoogle() async {
    try {
      print("DEBUG: Google Sign-In started...");

      // 2. This command triggers the "Choose an Account" window
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("DEBUG: User closed the window without picking an account.");
        return null;
      }

      print("DEBUG: Account selected: ${googleUser.email}");

      // 3. Get the tokens from the selection
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      print("DEBUG: Successfully signed in to Firebase!");
      return userCredential.user;

    } catch (e) {
      // 5. This will tell us if it's a DEVELOPER_ERROR or missing Support Email
      print("DEBUG: CRITICAL ERROR: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}