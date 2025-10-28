// lib/data/models/auth_state_model.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart'; // للوصول لـ supabase
import '../models/profile.dart';
import '../services/auth_service.dart';

class AuthStateModel with ChangeNotifier {
  final AuthService _authService = AuthService(client: supabase);

  User? _currentUser;
  Profile? _currentProfile;
  bool _isLoadingSession = true;

  User? get currentUser => _currentUser;

  Profile? get currentProfile => _currentProfile;

  bool get isLoadingSession => _isLoadingSession;

  bool get isLoggedIn => _currentUser != null && _currentProfile != null;

  String? get userRole => _currentProfile?.role;

  String? get userGroupId => _currentProfile?.groupId;

  // ✅ الـ Getter المطلوب لحل مشكلة 'isAdmin'
  bool get isAdmin => userRole == 'admin';

  // ✅ الـ Getter الجديد المطلوب لحل مشكلة 'isStudent'
  bool get isStudent => userRole == 'student';

  AuthStateModel() {
    _authService.client.auth.onAuthStateChange.listen((data) {
      _onAuthStateChange(data.event, data.session);
    });
    _loadInitialSession();
  }

  void _onAuthStateChange(AuthChangeEvent event, Session? session) {
    if (event == AuthChangeEvent.signedIn) {
      _currentUser = session?.user;
      reloadProfile();
    } else if (event == AuthChangeEvent.signedOut) {
      _currentUser = null;
      _currentProfile = null;
      _isLoadingSession = false;
    }
    notifyListeners();
  }

  Future<void> _loadInitialSession() async {
    _isLoadingSession = true;
    final session = _authService.client.auth.currentSession;
    if (session != null) {
      _currentUser = session.user;
      await reloadProfile();
    } else {
      _currentUser = null;
      _currentProfile = null;
    }
    _isLoadingSession = false;
    notifyListeners();
  }

  Future<void> reloadProfile() async {
    _isLoadingSession = true;
    notifyListeners();
    try {
      final data = await _authService.getCurrentUserProfile();
      _currentProfile = Profile.fromMap(data);
    } catch (e) {
      await _authService.signOut();
    }
    _isLoadingSession = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
