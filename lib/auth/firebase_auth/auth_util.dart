import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _fs = FirebaseFirestore.instance;

  /// 写/更新用户档案到 Firestore: users/{uid}
  /// - isNew == true 时会写入 created_time（首次注册或首次 Google 登录）
  Future<void> _upsertUserToFirestore(User user, {bool isNew = false}) async {
    final doc = _fs.collection('users').doc(user.uid);

    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      // 如果你只想要图上的三个字段，可不写下面这行
      // 'updated_time': FieldValue.serverTimestamp(),
    };

    // 和你截图一致：仅在新用户时写 created_time
    if (isNew) {
      data['created_time'] = FieldValue.serverTimestamp();
    }

    // merge: true 确保不会覆盖已有字段
    await doc.set(data, SetOptions(merge: true));
  }

  Future<User?> signUpWithEmail(
      BuildContext context, {
        required String email,
        required String password,
      }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        await _upsertUserToFirestore(user, isNew: true);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      _toast(context, e.message ?? 'Sign up failed');
      return null;
    }
  }

  Future<User?> signInWithEmail(
      BuildContext context, {
        required String email,
        required String password,
      }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        // 如果希望登录时也更新一次活跃时间，可打开下一行：
        // await _upsertUserToFirestore(user, isNew: false);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      _toast(context, e.message ?? 'Sign in failed');
      return null;
    }
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // 用户取消
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      final user = cred.user;

      if (user != null) {
        final isNew = cred.additionalUserInfo?.isNewUser ?? false;
        await _upsertUserToFirestore(user, isNew: isNew);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      _toast(context, e.message ?? 'Google sign-in failed');
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(
      BuildContext context, String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _toast(context, 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _toast(context, e.message ?? 'Failed to send reset email');
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

final authService = AuthService();
