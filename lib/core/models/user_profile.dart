class UserProfile {
  static String name = '';
  static String email = '';
  static String phone = '';
  static String address = '';
  // Jika true, menu Admin akan terlihat (bisa di-set saat development)
  static bool isAdmin = false;

  static Map<String, String> asMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }

  static void updateFromMap(Map<String, String> m) {
    name = m['name'] ?? name;
    email = m['email'] ?? email;
    phone = m['phone'] ?? phone;
    address = m['address'] ?? address;
  }
}
