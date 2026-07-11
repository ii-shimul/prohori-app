import '../data/secure_auth_storage.dart';
import '../data/supabase_auth_data_source.dart';
import 'auth_user.dart';

class AuthRepository {
  AuthRepository({
    required SupabaseAuthDataSource dataSource,
    required SecureAuthStorage secureStorage,
  })  : _dataSource = dataSource,
        _secureStorage = secureStorage;

  final SupabaseAuthDataSource _dataSource;
  final SecureAuthStorage _secureStorage;

  Stream<AuthUser?> get authStateChanges => _dataSource.authStateChanges;
  AuthUser? get currentUser => _dataSource.currentUser;

  Future<AuthUser> login({required String email, required String password}) {
    return _dataSource.signInWithSeededCredentials(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    try {
      await _dataSource.signOut();
    } finally {
      await _secureStorage.wipeDatabase();
    }
  }
}
