import '../user_profile.dart';

class AuthService {
  // In-memory users: email -> {name, password, isAdmin}
  static final Map<String, Map<String, dynamic>> _users = {
    // default admin account for testing
    'admin@cosvoria.com': {
      'name': 'Admin',
      'password': 'admin123',
      'isAdmin': true,
    }
  };

  /// Register a new user. Returns true if success, false if email exists.
  static bool register(String email, String name, String password) {
    if (_users.containsKey(email)) return false;
    _users[email] = {'name': name, 'password': password, 'isAdmin': false};
    return true;
  }

  /// Login with email and password. Returns user map or null.
  static Map<String, dynamic>? login(String email, String password) {
    final user = _users[email];
    if (user == null) return null;
    if (user['password'] == password) {
      // populate global UserProfile
      UserProfile.name = user['name'] as String;
      UserProfile.email = email;
      UserProfile.isAdmin = (user['isAdmin'] as bool?) ?? false;
      return {'email': email, 'name': user['name'], 'isAdmin': user['isAdmin']};
    }
    return null;
  }
}
