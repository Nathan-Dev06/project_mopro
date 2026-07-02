import 'package:flutter/foundation.dart';

/// A simple singleton manager to handle global wishlist state.
class WishlistManager {
  // Private constructor
  WishlistManager._privateConstructor();

  // The single instance
  static final WishlistManager instance = WishlistManager._privateConstructor();

  // ValueNotifier containing the list of favorited costume titles
  final ValueNotifier<List<String>> wishlistNotifier = ValueNotifier<List<String>>([]);

  /// Check if a costume is in the wishlist
  bool isWishlisted(String title) {
    return wishlistNotifier.value.contains(title);
  }

  /// Toggle a costume in the wishlist
  void toggleWishlist(String title) {
    final currentList = List<String>.from(wishlistNotifier.value);
    if (currentList.contains(title)) {
      currentList.remove(title);
    } else {
      currentList.add(title);
    }
    wishlistNotifier.value = currentList;
  }
}
