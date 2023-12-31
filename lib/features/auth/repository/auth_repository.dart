import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_providers.dart';
import 'package:reddit_clone/core/type_defs.dart';
import 'package:reddit_clone/models/user_model.dart';

//authRepository provider

final authRepositoryProvider = Provider((ref) => AuthRepository(
    auth: ref.read(authProvider),
    firestore: ref.read(firestoreProvider),
    googleSignIn: ref.read(googleSignInProvider)));

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required FirebaseAuth auth,
      required FirebaseFirestore firestore,
      required GoogleSignIn googleSignIn})
      : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

//Stream for authStatechange
  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      print('inside******');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      UserCredential userCredential;
      if (isFromLogin) {
        userCredential = await _auth.signInWithCredential(credential);
      } else {
        userCredential =
            await _auth.currentUser!.linkWithCredential(credential);
      }
      UserModel userModel;
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
            uid: userCredential.user!.uid,
            name: userCredential.user?.displayName ?? 'no name',
            profilePic:
                userCredential.user?.photoURL ?? Constants.avatarDefault,
            banner: Constants.bannerDefault,
            isAuthenticated: true,
            karma: 0,
            awards: ['til', 'gold', 'platinum', 'plusone']);

        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  FutureEither<UserModel> signInWithGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();
      UserModel userModel;

      userModel = UserModel(
          uid: userCredential.user!.uid,
          name: 'Guest',
          profilePic: Constants.avatarDefault,
          banner: Constants.bannerDefault,
          isAuthenticated: false,
          karma: 0,
          awards: []);

      await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      rethrow;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
          (event) => UserModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  void logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
