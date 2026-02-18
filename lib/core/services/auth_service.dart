// lib/core/services/auth_service.dart
//
// Wraps Firebase Auth and Cloud Firestore.
// All auth operations flow through here so callers never import
// firebase_auth or cloud_firestore directly.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final bool kycVerified;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.kycVerified = false,
  });

  factory UserProfile.fromDoc(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      kycVerified: data['kycVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'kycVerified': kycVerified,
      };
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Auth state stream ───────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Sign In ─────────────────────────────────────────────────────────────────

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Sign Up ─────────────────────────────────────────────────────────────────

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    // 1. Create Firebase Auth account
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    // 2. Persist display name on the Auth user object
    await credential.user!.updateDisplayName(fullName.trim());

    // 3. Save extended profile to Firestore
    await _db.collection('users').doc(uid).set({
      'fullName': fullName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'kycVerified': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // ── Sign Out ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Password Reset ──────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Fetch User Profile ──────────────────────────────────────────────────────

  Future<UserProfile?> fetchProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromDoc(uid, doc.data()!);
  }

  // ── Map Firebase error codes → friendly messages ────────────────────────────

  static String mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
