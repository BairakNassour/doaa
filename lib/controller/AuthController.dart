// import 'dart:async';
// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // أضف هذه المكتبة
// import 'package:http/http.dart' as http;
// import 'package:doaa/component/general_url.dart'; // تأكد من وجود رابط الـ Laravel هنا

// class SocialAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

//   // تهيئة المستمع لجوجل (نفس طريقتك بالضبط)
//   void initSocialListeners(Function(User?, Map<String, dynamic>?) onUserChanged) {
//     _googleSignIn.initialize().then((_) {
//       _googleSignIn.authenticationEvents.listen((event) async {
//         GoogleSignInAccount? googleUser;

//         if (event is GoogleSignInAuthenticationEventSignIn) {
//           googleUser = event.user;
//         } else {
//           googleUser = null;
//         }

//         if (googleUser != null) {
//           final googleAuth = await googleUser.authentication;
//           final credential = GoogleAuthProvider.credential(
//             idToken: googleAuth.idToken,
//           );
          
//           final userCredential = await _auth.signInWithCredential(credential);

//           final laravelData = await syncUserWithLaravel(userCredential.user!, 'google');
          
//           onUserChanged(userCredential.user, laravelData);
//         } else {
//           onUserChanged(null, null);
//         }
//       });
//     });
//   }

//   // دالة المزامنة مع Laravel (محدثة لتقبل الـ Provider)
//   Future<Map<String, dynamic>?> syncUserWithLaravel(User user, String provider) async {
//     try {
//       final response = await http.post(
//         Uri.parse("$general_url/social-login"), // الرابط الموحد في لارافيل
//         headers: {"Content-Type": "application/json", "Accept": "application/json"},
//         body: jsonEncode({
//           "email": user.email,
//           "name": user.displayName,
//           "avatar": user.photoURL,
//           "social_id": user.uid,
//           "provider": provider,
//         }),
//       );
//       print(response.body);

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       print("Laravel Sync Error: $e");
//     }
//     return null;
//   }

//   // تشغيل عملية تسجيل الدخول لجوجل
//   Future<void> signInWithGoogle() async {
//     try {
//       await _googleSignIn.authenticate();
//     } catch (e) {
//       print("Google Auth Error: $e");
//     }
//   }

//   // تشغيل عملية تسجيل الدخول لأبل (إضافة اختيارية قوية لمشروعك)
//   // Future<void> signInWithApple(Function(User?, Map<String, dynamic>?) onUserChanged) async {
//   //   try {
//   //     final appleCredential = await SignInWithApple.getAppleIDCredential(
//   //       scopes: [
//   //         AppleIDAuthorizationScope.email,
//   //         AppleIDAuthorizationScope.fullName,
//   //       ],
//   //     );

//   //     final OAuthCredential credential = OAuthProvider("apple.com").credential(
//   //       idToken: appleCredential.identityToken,
//   //       accessToken: appleCredential.authorizationCode,
//   //     );

//   //     final userCredential = await _auth.signInWithCredential(credential);
//   //     final laravelData = await syncUserWithLaravel(userCredential.user!, 'apple');
      
//   //     onUserChanged(userCredential.user, laravelData);
//   //   } catch (e) {
//   //     print("Apple Auth Error: $e");
//   //   }
//   // }

//   Future<void> signOut() async {
//     await _auth.signOut();
//     await _googleSignIn.signOut();
//   }
// }