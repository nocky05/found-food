import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:found_food/features/auth/domain/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _user = _authService.currentUser;
    // Écouter les changements d'état d'auth
    _authService.authStateChanges.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signUp(email: email, password: password, fullName: fullName);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = "Une erreur inattendue est survenue";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = "Une erreur inattendue est survenue";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
