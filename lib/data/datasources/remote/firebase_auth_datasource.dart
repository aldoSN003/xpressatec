import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

abstract class FirebaseAuthDatasource {
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String nombre,
    required String rol,
    String? fechaNacimiento,
    String? cedula,
  });

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<firebase_auth.User?> get authStateChanges;
}

class FirebaseAuthDatasourceImpl implements FirebaseAuthDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDatasourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String nombre,
    required String rol,
    String? fechaNacimiento,
    String? cedula,
  }) async {
    try {
      // 1. Create Firebase Auth user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('No se pudo crear el usuario');
      }

      final firebaseUid = userCredential.user!.uid;

      // 2. Create user profile in Firestore
      final userModel = UserModel(
        id: firebaseUid.hashCode, // Generate int ID from Firebase UID
        uuid: firebaseUid,
        nombre: nombre,
        email: email,
        rol: rol,
        fechaCreacion: DateTime.now(),
        fechaNacimiento: fechaNacimiento,
        cedula: cedula,
      );

      // 3. Save to Firestore
      await _firestore
          .collection('users')
          .doc(firebaseUid)
          .set(userModel.toJson());

      // 4. Update display name in Firebase Auth
      await userCredential.user!.updateDisplayName(nombre);

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      // If Firestore fails, delete the auth user
      try {
        await _firebaseAuth.currentUser?.delete();
      } catch (_) {}
      throw Exception('Error al registrar: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('No se pudo iniciar sesión');
      }

      final firebaseUid = userCredential.user!.uid;

      // 2. Get user profile from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUid)
          .get();

      if (!userDoc.exists) {
        throw Exception('No se encontró el perfil del usuario');
      }

      final userData = userDoc.data()!;

      // Make sure we have the Firebase UID in the data
      userData['uid'] = firebaseUid;
      userData['uuid'] = firebaseUid;

      return UserModel.fromJson(userData);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Get user profile from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;

      // Make sure we have the Firebase UID in the data
      userData['uid'] = firebaseUser.uid;
      userData['uuid'] = firebaseUser.uid;

      return UserModel.fromJson(userData);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Stream<firebase_auth.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  Exception _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('La contraseña debe tener al menos 6 caracteres');
      case 'email-already-in-use':
        return Exception('Ya existe una cuenta con este email');
      case 'user-not-found':
        return Exception('No se encontró usuario con este email');
      case 'wrong-password':
        return Exception('Contraseña incorrecta');
      case 'invalid-email':
        return Exception('Email inválido');
      case 'user-disabled':
        return Exception('Esta cuenta ha sido deshabilitada');
      case 'too-many-requests':
        return Exception('Demasiados intentos. Intenta más tarde');
      case 'operation-not-allowed':
        return Exception('Operación no permitida');
      case 'invalid-credential':
        return Exception('Credenciales inválidas');
      default:
        return Exception(e.message ?? 'Error de autenticación');
    }
  }
}