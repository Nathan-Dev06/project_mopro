import 'package:flutter/material.dart';
import 'package:project_mopro/features/customer/pages/detail_costume_page.dart';
import 'package:project_mopro/features/customer/pages/notification_page.dart';
import 'package:project_mopro/features/customer/pages/profile_page.dart';
import 'package:project_mopro/core/managers/voucher_manager.dart';
import 'package:project_mopro/core/managers/wishlist_manager.dart';
import 'package:project_mopro/core/managers/costume_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// =============================================
// DESIGN SYSTEM â€” Kick Avenue Aesthetic
// Clean, Light, Premium Minimalist
// Monochromatic: Black, White, Soft Greys
// =============================================

// ==================== DATA MODELS ====================
class CostumeData {
  final String title;
  final String series;
  final String price;
  final String condition;
  final String image;
  final String include;
  final String size; // e.g. "S|M|L|XL" or "All Size"
  final bool isReady;
  final String category;
  final double rating;
  final int reviewCount;
  final Map<String, int>? sizeStocks;

  const CostumeData({
    required this.title,
    required this.series,
    required this.price,
    required this.condition,
    required this.image,
    required this.include,
    required this.size,
    required this.isReady,
    this.category = 'Anime',
    this.rating = 4.8,
    this.reviewCount = 12,
    this.sizeStocks,
  });

  Map<String, int> get activeStocks {
    if (sizeStocks != null) return sizeStocks!;
    final defaultMap = <String, int>{};
    for (var sz in sizeList) {
      defaultMap[sz] = 5;
    }
    return defaultMap;
  }

  int get totalStock {
    return activeStocks.values.fold(0, (sum, val) => sum + val);
  }

  /// Size list from string. "All Size" → ['All Size']
  List<String> get sizeList {
    if (size == 'All Size') return ['All Size'];
    if (size.contains('|')) {
      return size.split('|').map((s) => s.trim()).toList();
    }
    if (size.contains(',')) {
      return size.split(',').map((s) => s.trim()).toList();
    }
    if (size.contains(' - ')) {
      return size.split(' - ').map((s) => s.trim()).toList();
    }
    return [size];
  }

  bool get hasMultipleSizes => sizeList.length > 1;

  /// Compact size display: "S|M" → "S|M"
  String get sizeDisplay {
    if (size == 'All Size') return 'All Size';
    return sizeList.join('|');
  }

  factory CostumeData.fromMap(Map<String, dynamic> map) {
    Map<String, int>? sizeStocks;
    if (map['sizeStocks'] != null && map['sizeStocks'] is Map) {
      sizeStocks = Map<String, int>.from(
        (map['sizeStocks'] as Map).map((k, v) => MapEntry(k.toString(), v as int)),
      );
    }
    return CostumeData(
      title: map['title'] ?? '',
      series: map['series'] ?? '',
      price: map['price'] ?? '0',
      condition: map['condition'] ?? '100%',
      image: map['image'] ?? '',
      include: map['include'] ?? '',
      size: map['size'] ?? 'All Size',
      isReady: map['isReady'] ?? true,
      category: map['category'] ?? 'Anime',
      rating: (map['rating'] ?? 4.8).toDouble(),
      reviewCount: map['reviewCount'] ?? 12,
      sizeStocks: sizeStocks,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'series': series,
        'price': price,
        'condition': condition,
        'image': image,
        'include': include,
        'size': size,
        'isReady': isReady,
        'category': category,
        'rating': rating,
        'reviewCount': reviewCount,
        'sizeStocks': sizeStocks,
      };
}

// ==================== DESIGN TOKENS ====================
/// Strict monochromatic palette â€” Kick Avenue inspired
class _C {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5); // light grey product bg
  static const Color black = Color(0xFF111111); // primary text & CTA
  static const Color grey500 = Color(0xFF888888); // muted text
  static const Color grey400 = Color(0xFFB0B0B0); // tertiary text
  static const Color grey300 = Color(0xFFD5D5D5); // borders
  static const Color grey100 = Color(0xFFF2F2F2); // search bg
  static const Color white = Color(0xFFFFFFFF);
  static const Color readyGreen = Color(0xFF22C55E); // availability: Ready
  static const Color readyGreenBg = Color(0xFFDCFCE7);
  static const Color rentedRed = Color(0xFFEF4444); // availability: Rented
  static const Color rentedRedBg = Color(0xFFFEE2E2);
}

// ==================== STATIC COSTUME DATA ====================
const List<CostumeData> kCostumes = [
  // ==========================================
  // â”€â”€ 1. KATEGORI ANIME (10 Item) â”€â”€
  // ==========================================
  CostumeData(
    title: "Monkey D. Luffy (Wano)",
    series: "One Piece",
    price: "120,000",
    condition: "95%",
    image: "assets/images/luffy_wano.jpg",
    include: "Red Kimono, Fire Pattern Haori, Straw Hat, Wooden Sandals",
    size: "L|XL",
    isReady: true,
    category: "Anime",
    rating: 4.9,
    reviewCount: 34,
  ),
  CostumeData(
    title: "Satoru Gojo (Hidden Inventory)",
    series: "Jujutsu Kaisen",
    price: "145,000",
    condition: "98%",
    image: "assets/images/gojo.jpg",
    include: "Black Shirt, Trousers, Black Sunglasses, White Wig",
    size: "S|M|L",
    isReady: false,
    category: "Anime",
    rating: 5.0,
    reviewCount: 58,
  ),
  CostumeData(
    title: "Nezuko Kamado Full Set",
    series: "Demon Slayer",
    price: "135,000",
    condition: "97%",
    image: "assets/images/nezuko.jpg",
    include: "Pink Kimono, Red Obi, Bamboo Prop, Long Black Wig",
    size: "S|M",
    isReady: true,
    category: "Anime",
    rating: 4.8,
    reviewCount: 29,
  ),
  CostumeData(
    title: "Tanjiro Kamado",
    series: "Demon Slayer",
    price: "130,000",
    condition: "96%",
    image: "assets/images/tanjiro.jpg",
    include: "Checkered Haori, Black Kimono, Wig, Hanafuda Earrings",
    size: "S|M|L|XL",
    isReady: true,
    category: "Anime",
    rating: 4.7,
    reviewCount: 22,
  ),
  CostumeData(
    title: "Zero Two (002)",
    series: "Darling in the FranXX",
    price: "155,000",
    condition: "99%",
    image: "assets/images/zero_two.jpg",
    include: "Red Uniform, Horn Headband, Long Pink Wig, Gloves",
    size: "S|M",
    isReady: true,
    category: "Anime",
    rating: 4.9,
    reviewCount: 41,
  ),
  CostumeData(
    title: "Levi Ackerman (Survey Corps)",
    series: "Attack on Titan",
    price: "150,000",
    condition: "92%",
    image: "assets/images/levi.jpg",
    include: "Jacket, White Shirt, Cravat, Harness, Cape",
    size: "S|M|L",
    isReady: true,
    category: "Anime",
    rating: 4.9,
    reviewCount: 64,
  ),
  CostumeData(
    title: "Anya Forger (Eden Academy)",
    series: "Spy x Family",
    price: "100,000",
    condition: "98%",
    image: "assets/images/anya.jpg",
    include: "Black Dress, White Shirt, Ribbon, Horn Hairclips",
    size: "S|M",
    isReady: true,
    category: "Anime",
    rating: 4.8,
    reviewCount: 42,
  ),
  CostumeData(
    title: "Frieren",
    series: "Frieren: Beyond Journey's End",
    price: "140,000",
    condition: "99%",
    image: "assets/images/frieren.jpg",
    include: "White Cape, Striped Dress, Pantyhose, Elf Ears, Staff Prop",
    size: "M|L",
    isReady: false,
    category: "Anime",
    rating: 5.0,
    reviewCount: 15,
  ),
  CostumeData(
    title: "UA High Uniform (Izuku)",
    series: "My Hero Academia",
    price: "110,000",
    condition: "96%",
    image: "assets/images/izuku.jpg",
    include: "Blue Blazer, Trousers, Tie, UA Emblem",
    size: "S|M|L",
    isReady: true,
    category: "Anime",
    rating: 4.8,
    reviewCount: 33,
  ),
  CostumeData(
    title: "Emilia (Re:Zero)",
    series: "Re:Zero",
    price: "165,000",
    condition: "98%",
    image: "assets/images/emilia.jpg",
    include: "White-Purple Gown, Flower Crown, Long Silver Wig, Cloak",
    size: "S|M",
    isReady: true,
    category: "Anime",
    rating: 4.9,
    reviewCount: 38,
  ),

  // ==========================================
  // â”€â”€ 2. KATEGORI GAMES (10 Item) â”€â”€
  // ==========================================
  CostumeData(
    title: "Link (Breath of The Wild)",
    series: "The Legend of Zelda",
    price: "160,000",
    condition: "93%",
    image: "assets/images/link.jpg",
    include: "Blue Shirt, Brown Pants, Leather Belt, Sword & Shield Prop",
    size: "M|L",
    isReady: true,
    category: "Games",
    rating: 4.6,
    reviewCount: 18,
  ),
  CostumeData(
    title: "Kratos (God of War)",
    series: "God of War",
    price: "200,000",
    condition: "91%",
    image: "assets/images/kratos.jpg",
    include: "Full Armor, Grey Body Paint, Leviathan Axe Prop, Cape",
    size: "L|XL",
    isReady: true,
    category: "Games",
    rating: 4.8,
    reviewCount: 15,
  ),
  CostumeData(
    title: "Jinx (Arcane)",
    series: "League of Legends",
    price: "170,000",
    condition: "97%",
    image: "assets/images/jinx.jpg",
    include: "Blue Jacket, Shorts, Blue Braid Wig, Minigun Prop",
    size: "S|M|L",
    isReady: false,
    category: "Games",
    rating: 4.9,
    reviewCount: 27,
  ),
  CostumeData(
    title: "Killjoy Default Jacket",
    series: "Valorant",
    price: "145,000",
    condition: "95%",
    image: "assets/images/killjoy.jpg",
    include: "Yellow Puffer Jacket, Beanie, Round Glasses, Green Shirt",
    size: "M|L",
    isReady: true,
    category: "Games",
    rating: 4.8,
    reviewCount: 31,
  ),
  CostumeData(
    title: "Clove Troublemaker",
    series: "Valorant",
    price: "155,000",
    condition: "99%",
    image: "assets/images/clove.jpg",
    include: "Pink Jacket, Choker, Butterfly Accessories, Short Pink Wig",
    size: "S|M",
    isReady: true,
    category: "Games",
    rating: 4.9,
    reviewCount: 12,
  ),
  CostumeData(
    title: "Raiden Shogun",
    series: "Genshin Impact",
    price: "185,000",
    condition: "96%",
    image: "assets/images/raiden.jpg",
    include: "Purple Kimono, Obi, Hairpin, Long Purple Wig",
    size: "M|L|XL",
    isReady: false,
    category: "Games",
    rating: 4.7,
    reviewCount: 56,
  ),
  CostumeData(
    title: "Kafka",
    series: "Honkai: Star Rail",
    price: "175,000",
    condition: "97%",
    image: "assets/images/kafka.jpg",
    include: "White Shirt, Black Coat, Shorts, Sunglasses, Pantyhose",
    size: "M|L",
    isReady: true,
    category: "Games",
    rating: 4.9,
    reviewCount: 48,
  ),
  CostumeData(
    title: "Tifa Lockhart",
    series: "Final Fantasy VII Remake",
    price: "140,000",
    condition: "94%",
    image: "assets/images/tifa.jpg",
    include: "White Tank Top, Suspenders, Black Skirt, Gloves, Red Boots",
    size: "S|M|L",
    isReady: true,
    category: "Games",
    rating: 4.8,
    reviewCount: 39,
  ),
  CostumeData(
    title: "Super Mario Classic",
    series: "Super Mario Bros",
    price: "85,000",
    condition: "90%",
    image: "assets/images/mario.jpg",
    include: "Red Shirt, Blue Overalls, Red Hat, Fake Mustache",
    size: "All Size",
    isReady: true,
    category: "Games",
    rating: 4.5,
    reviewCount: 22,
  ),
  CostumeData(
    title: "Chun-Li",
    series: "Street Fighter",
    price: "135,000",
    condition: "93%",
    image: "assets/images/chunli.jpg",
    include: "Blue Qipao, White Boots, Spiked Bracelets, Hair Buns",
    size: "M|L",
    isReady: true,
    category: "Games",
    rating: 4.6,
    reviewCount: 27,
  ),

  // ==========================================
  // â”€â”€ 3. KATEGORI MOVIES (10 Item) â”€â”€
  // ==========================================
  CostumeData(
    title: "DalÃ­ Mask & Jumpsuit",
    series: "Money Heist",
    price: "100,000",
    condition: "90%",
    image: "assets/images/money_heist.jpg",
    include: "Red Jumpsuit, DalÃ­ Mask, Gloves, Weapon Prop",
    size: "All Size",
    isReady: true,
    category: "Movies",
    rating: 4.7,
    reviewCount: 21,
  ),
  CostumeData(
    title: "Spider-Man (Miles Morales)",
    series: "Spider-Verse",
    price: "180,000",
    condition: "99%",
    image: "assets/images/spiderman.jpg",
    include: "Full Body Suit, Lens Mask, Hoodie Jacket, Shorts",
    size: "S|M|L",
    isReady: true,
    category: "Movies",
    rating: 4.9,
    reviewCount: 47,
  ),
  CostumeData(
    title: "Thanos Armor Full",
    series: "Avengers: Endgame",
    price: "250,000",
    condition: "88%",
    image: "assets/images/thanos.jpg",
    include: "Full Armor Set, Helmet, Infinity Gauntlet, Purple Cape",
    size: "XL",
    isReady: true,
    category: "Movies",
    rating: 4.5,
    reviewCount: 11,
  ),
  CostumeData(
    title: "Batman (Dark Knight)",
    series: "DC Comics",
    price: "195,000",
    condition: "94%",
    image: "assets/images/batman.jpg",
    include: "Full Black Bodysuit, Cape, Cowl, Utility Belt, Batarang",
    size: "M|L|XL",
    isReady: true,
    category: "Movies",
    rating: 4.8,
    reviewCount: 31,
  ),
  CostumeData(
    title: "Wonder Woman",
    series: "DC Comics",
    price: "185,000",
    condition: "96%",
    image: "assets/images/wonder_women.jpg",
    include: "Gold-Red Armor, Tiara, Lasso Prop, Shield & Sword",
    size: "S|M|L",
    isReady: true,
    category: "Movies",
    rating: 4.9,
    reviewCount: 24,
  ),
  CostumeData(
    title: "Deadpool Suit",
    series: "Deadpool",
    price: "190,000",
    condition: "95%",
    image: "assets/images/deadpool.jpg",
    include: "Red-Black Bodysuit, Mask, Utility Belt, Katana Prop",
    size: "M|L|XL",
    isReady: true,
    category: "Movies",
    rating: 4.9,
    reviewCount: 53,
  ),
  CostumeData(
    title: "Gryffindor Student",
    series: "Harry Potter",
    price: "110,000",
    condition: "97%",
    image: "assets/images/harry_potter.jpg",
    include: "Black Robe, Gryffindor Tie, Magic Wand Prop, Glasses",
    size: "S|M|L",
    isReady: true,
    category: "Movies",
    rating: 4.7,
    reviewCount: 41,
  ),
  CostumeData(
    title: "Barbie Pink Cowgirl",
    series: "Barbie (2023)",
    price: "125,000",
    condition: "98%",
    image: "assets/images/barbie.jpg",
    include: "Pink Vest, Flared Pants, White Cowboy Hat, Bandana",
    size: "S|M",
    isReady: true,
    category: "Movies",
    rating: 4.8,
    reviewCount: 35,
  ),
  CostumeData(
    title: "Joker (Arthur Fleck)",
    series: "Joker",
    price: "160,000",
    condition: "92%",
    image: "assets/images/joker.jpg",
    include: "Red Suit, Yellow Vest, Green Shirt, Face Paint Kit",
    size: "L|XL",
    isReady: false,
    category: "Movies",
    rating: 4.6,
    reviewCount: 28,
  ),
  CostumeData(
    title: "Jedi Knight",
    series: "Star Wars",
    price: "130,000",
    condition: "94%",
    image: "assets/images/jedi.jpg",
    include: "Brown Cloak, Tunic, Belt, Lightsaber Prop",
    size: "M|L|XL",
    isReady: true,
    category: "Movies",
    rating: 4.5,
    reviewCount: 19,
  ),

  // ==========================================
  // â”€â”€ 4. KATEGORI PROPS & WEAPONS (10 Item) â”€â”€
  // ==========================================
  CostumeData(
    title: "Shusui Katana Prop (104cm)",
    series: "One Piece",
    price: "45,000",
    condition: "95%",
    image: "assets/images/shusui.jpg",
    include: "1x Wooden Katana, Scabbard",
    size: "104 cm",
    isReady: true,
    category: "Props & Weapons",
    rating: 4.9,
    reviewCount: 82,
  ),
  CostumeData(
    title: "Leviathan Axe Replica",
    series: "God of War",
    price: "75,000",
    condition: "90%",
    image: "assets/images/leviathan_axe.jpg",
    include: "1x Foam Axe Replica",
    size: "100 cm",
    isReady: false,
    category: "Props & Weapons",
    rating: 4.8,
    reviewCount: 45,
  ),
  CostumeData(
    title: "Captain America Shield",
    series: "Marvel Avengers",
    price: "60,000",
    condition: "92%",
    image: "assets/images/cap_shield.jpg",
    include: "1x Metal Replica Shield (1:1)",
    size: "60 cm",
    isReady: true,
    category: "Props & Weapons",
    rating: 4.9,
    reviewCount: 61,
  ),
  CostumeData(
    title: "Elder Wand (Dumbledore)",
    series: "Harry Potter",
    price: "25,000",
    condition: "98%",
    image: "assets/images/elder_wand.jpg",
    include: "1x Resin Wand, Wand Box",
    size: "38 cm",
    isReady: true,
    category: "Props & Weapons",
    rating: 4.7,
    reviewCount: 39,
  ),
  CostumeData(
    title: "Lightsaber FX (Blue)",
    series: "Star Wars",
    price: "85,000",
    condition: "96%",
    image: "assets/images/lightsaber.jpg",
    include: "1x LED Lightsaber, Charging Cable",
    size: "100 cm",
    isReady: true,
    category: "Props & Weapons",
    rating: 4.8,
    reviewCount: 52,
  ),
  CostumeData(
    title: "Holy Lyre der Himmel",
    series: "Genshin Impact",
    price: "50,000",
    condition: "97%",
    image: "assets/images/venti_lyre.jpg",
    include: "1x Venti Lyre Wooden Prop",
    size: "40 cm",
    isReady: true,
    category: "Props & Weapons",
    rating: 4.9,
    reviewCount: 28,
  ),
  CostumeData(
    title: "Kunai & Shuriken Set",
    series: "Naruto",
    price: "20,000",
    condition: "99%",
    image: "assets/images/kunai_set.jpg",
    include: "3x Plastic Kunai, 1x Shuriken",
    size: "All Size",
    isReady: true,
    category: "Props & Weapons",
    rating: 4.6,
    reviewCount: 74,
  ),
  CostumeData(
    title: "Master Sword Replica",
    series: "The Legend of Zelda",
    price: "65,000",
    condition: "93%",
    image: "assets/images/master_sword.jpg",
    include: "1x PU Foam Sword, Scabbard",
    size: "105 cm",
    isReady: false,
    category: "Props & Weapons",
    rating: 4.8,
    reviewCount: 33,
  ),
  CostumeData(
    title: "Mjolnir Hammer",
    series: "Thor / Marvel",
    price: "55,000",
    condition: "94%",
    image: "assets/images/mjolnir.jpg",
    include: "1x Resin Hammer Prop",
    size: "44 cm",
    isReady: true,
    category: "Props & Weapons",
    rating: 4.7,
    reviewCount: 48,
  ),
  CostumeData(
    title: "Fishbones Rocket Launcher",
    series: "League of Legends",
    price: "150,000",
    condition: "88%",
    image: "assets/images/fishbones.jpg",
    include: "1x Large EVA Foam Rocket Launcher",
    size: "120 cm",
    isReady: true,
    category: "Props & Weapons",
    rating: 4.9,
    reviewCount: 19,
  ),

  // ==========================================
  // â”€â”€ 5. KATEGORI ACCESSORIES (10 Item) â”€â”€
  // ==========================================
  CostumeData(
    title: "Gojo Satoru Blindfold",
    series: "Jujutsu Kaisen",
    price: "15,000",
    condition: "99%",
    image: "assets/images/gojo_blindfold.jpg",
    include: "1x Black Elastic Blindfold",
    size: "All Size",
    isReady: true,
    category: "Accessories",
    rating: 4.8,
    reviewCount: 105,
  ),
  CostumeData(
    title: "Tanjiro Hanafuda Earrings",
    series: "Demon Slayer",
    price: "10,000",
    condition: "100%",
    image: "assets/images/hanafuda.jpg",
    include: "1x Pair Acrylic Earrings",
    size: "All Size",
    isReady: true,
    category: "Accessories",
    rating: 4.9,
    reviewCount: 132,
  ),
  CostumeData(
    title: "Electro Vision Keychain",
    series: "Genshin Impact",
    price: "12,000",
    condition: "98%",
    image: "assets/images/electro_vision.jpg",
    include: "1x Glow in the dark Vision Pin",
    size: "All Size",
    isReady: true,
    category: "Accessories",
    rating: 4.7,
    reviewCount: 67,
  ),
  CostumeData(
    title: "Akatsuki Ring Set",
    series: "Naruto",
    price: "25,000",
    condition: "95%",
    image: "assets/images/akatsuki_rings.jpg",
    include: "10x Metal Rings in Box",
    size: "Adjustable",
    isReady: false,
    category: "Accessories",
    rating: 4.8,
    reviewCount: 88,
  ),
  CostumeData(
    title: "Nezuko Bamboo Muzzle",
    series: "Demon Slayer",
    price: "15,000",
    condition: "97%",
    image: "assets/images/bamboo_muzzle.jpg",
    include: "1x Bamboo Prop with Red Ribbon",
    size: "All Size",
    isReady: true,
    category: "Accessories",
    rating: 4.6,
    reviewCount: 54,
  ),
  CostumeData(
    title: "Cyberpunk LED Visor",
    series: "Cyberpunk 2077",
    price: "35,000",
    condition: "99%",
    image: "assets/images/led_visor.jpg",
    include: "1x RGB LED Glasses, Batteries",
    size: "All Size",
    isReady: true,
    category: "Accessories",
    rating: 4.9,
    reviewCount: 41,
  ),
  CostumeData(
    title: "Elf Ears Prosthetics",
    series: "General Fantasy",
    price: "10,000",
    condition: "100%",
    image: "assets/images/elf_ears.jpg",
    include: "1x Pair Silicone Elf Ears",
    size: "All Size",
    isReady: true,
    category: "Accessories",
    rating: 4.5,
    reviewCount: 92,
  ),
  CostumeData(
    title: "Anya Horn Hairclips",
    series: "Spy x Family",
    price: "15,000",
    condition: "98%",
    image: "assets/images/anya_horns.jpg",
    include: "1x Pair Black Cone Hairclips",
    size: "All Size",
    isReady: true,
    category: "Accessories",
    rating: 4.8,
    reviewCount: 36,
  ),
  CostumeData(
    title: "Harry Potter Glasses",
    series: "Harry Potter",
    price: "10,000",
    condition: "96%",
    image: "assets/images/hp_glasses.jpg",
    include: "1x Round Metal Glasses (No Lens)",
    size: "All Size",
    isReady: true,
    category: "Accessories",
    rating: 4.7,
    reviewCount: 77,
  ),
  CostumeData(
    title: "Killjoy Yellow Beanie",
    series: "Valorant",
    price: "20,000",
    condition: "99%",
    image: "assets/images/kj_beanie.jpg",
    include: "1x Knitted Yellow Hat",
    size: "All Size",
    isReady: true,
    category: "Accessories",
    rating: 4.9,
    reviewCount: 49,
  ),
];

// ==================== MAIN HOME PAGE ====================
class MainHomePage extends StatefulWidget {
  final VoidCallback? onProfileTapped;
  const MainHomePage({Key? key, this.onProfileTapped}) : super(key: key);
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final TextEditingController _searchController = TextEditingController();

  // â”€â”€ Kick Avenue-style category filter tab state â”€â”€
  String _selectedTab = 'All';
  static const List<String> _categoryTabs = [
    'All',
    'Anime',
    'Games',
    'Movies',
    'Props & Weapons',
    'Accessories',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('main_home_page_scaffold'),
      backgroundColor: _C.bg,
      // â”€â”€ Section A: Top App Bar â”€â”€
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        key: const Key('home_scroll_view'),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Section B: Immediate Search & Filter â”€â”€
            const SizedBox(height: 4),
            _buildSearchAndFilter(),

            // â”€â”€ Kick Avenue-style Category Filter Tabs â”€â”€
            const SizedBox(height: 10),
            _buildCategoryTabs(),

            // â”€â”€ Section D: Compact Promo Banner â”€â”€
            const SizedBox(height: 14),
            _buildPromoBanner(),

            // â”€â”€ Section E: Trust Badges Bar â”€â”€
            const SizedBox(height: 14),
            _buildTrustBadges(),

            // â”€â”€ Section G: Main Catalog Grid â”€â”€
            const SizedBox(height: 14),
            _buildCatalogHeader(),
            const SizedBox(height: 10),
            _buildCatalogGrid(),

            // Bottom padding
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  A. TOP APP BAR
  //  Bold "COSVORIA" on left, Notification + Profile on right
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      key: const Key('cosvoria_app_bar'),
      backgroundColor: _C.bg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 52,
      centerTitle: false,
      title: const Text(
        "COSVORIA",
        style: TextStyle(
          color: _C.black,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          fontSize: 18,
        ),
      ),
      actions: [
        // Notification bell icon
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('global_notifications')
              .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))))
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            bool hasNew = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
            return IconButton(
              key: const Key('notification_button'),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded, color: _C.black, size: 22),
                  if (hasNew)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationPage()),
                );
              },
              splashRadius: 20,
            );
          }
        ),
        // Profile circle avatar
        GestureDetector(
          onTap: () {
            if (widget.onProfileTapped != null) {
              widget.onProfileTapped!();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 2),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _C.surface,
                border: Border.all(color: _C.grey300, width: 1),
              ),
              child:
                  const Icon(Icons.person_rounded, color: _C.grey500, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  B. IMMEDIATE SEARCH & FILTER
  //  Clean grey horizontal Row: SearchBar + solid black Filter btn
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _C.grey100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: _C.grey400, size: 20),
            const SizedBox(width: 10),
            // Search input field
            Expanded(
              child: TextField(
                key: const Key('search_field'),
                controller: _searchController,
                style: const TextStyle(
                  color: _C.black,
                  fontSize: 13,
                ),
                decoration: const InputDecoration(
                  hintText: "Search costumes, anime, or characters...",
                  hintStyle: TextStyle(
                    color: _C.grey400,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  KICK AVENUE-STYLE CATEGORY FILTER TABS
  //  Pure text, no icons â€” active tab has bold black text + underline
  //  Uses SingleChildScrollView + BouncingScrollPhysics
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        key: const Key('category_tabs_scroll'),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _categoryTabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isActive = _selectedTab == tab;

            return GestureDetector(
              key: Key('category_tab_$index'),
              onTap: () {
                setState(() => _selectedTab = tab);
              },
              child: Padding(
                // Comfortable horizontal spacing between tabs
                padding: EdgeInsets.only(
                  right: index < _categoryTabs.length - 1 ? 24 : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tab label text
                    Text(
                      tab,
                      style: TextStyle(
                        color: isActive ? _C.black : _C.grey500,
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Active underline indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2,
                      width: isActive ? 20 : 0,
                      decoration: BoxDecoration(
                        color: _C.black,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  D. COMPACT PROMO BANNER
  //  Minimalist light grey promo container
  //  Only ONE "Claim Voucher" CTA â€” no duplicate buttons
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        key: const Key('promo_banner'),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1E1E), Color(0xFF3A3A3A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Background Circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              right: 60,
              bottom: -40,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            
            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Promo badge with glass effect
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.flash_on_rounded,
                                color: Color(0xFFFFD700),
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "LIMITED OFFER",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Main promo copy
                        const Text(
                          "EUPHORIA DEALS II",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Get 20% OFF for your first rental!",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        
                        // Call to Action
                        ValueListenableBuilder<List<Voucher>>(
                          valueListenable: VoucherManager.instance.vouchersNotifier,
                          builder: (context, vouchers, _) {
                            final voucher = VoucherManager.instance.getVoucher('EUPHORIA20');
                            final isClaimed = voucher?.isClaimed ?? false;
                            
                            return GestureDetector(
                              key: const Key('claim_voucher_button'),
                              onTap: isClaimed ? null : () {
                                VoucherManager.instance.claimVoucher('EUPHORIA20');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(Icons.check_circle_outline, color: Colors.white),
                                        SizedBox(width: 12),
                                        Text('Voucher claimed successfully!'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green.shade700,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isClaimed
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isClaimed ? [] : [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Text(
                                  isClaimed ? "Claimed" : "Claim Voucher",
                                  style: TextStyle(
                                    color: isClaimed ? Colors.white54 : Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Divider
                  Container(
                    width: 1,
                    height: 90,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.white.withOpacity(0.15),
                  ),
                  
                  // Percentage Text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "20%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "OFF",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  E. TRUST BADGES BAR
  //  Thin horizontal bar â€” soft mint green/teal background
  //  3 badges: "100% Premium", "Fresh & Clean", "Fast Delivery"
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildTrustBadges() {
    return const SizedBox.shrink();
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  G. MAIN CATALOG GRID â€” 2-Column Portrait
  //  Section Title: "Costume Catalog" (font size 16, bold)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildCatalogHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "Costume Catalog",
        style: TextStyle(
          color: _C.black,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildCatalogGrid() {
    final searchQuery = _searchController.text.trim().toLowerCase();

    return ValueListenableBuilder<List<CostumeData>>(
      valueListenable: CostumeManager.instance.costumesNotifier,
      builder: (context, allCostumes, child) {
        // Filter costumes berdasarkan tab yang dipilih dan search query
        final filteredCostumes = allCostumes.where((costume) {
          final matchesTab = _selectedTab == 'All' || costume.category == _selectedTab;
          final matchesSearch = searchQuery.isEmpty ||
              costume.title.toLowerCase().contains(searchQuery) ||
              costume.series.toLowerCase().contains(searchQuery) ||
              costume.category.toLowerCase().contains(searchQuery);
          return matchesTab && matchesSearch;
        }).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: filteredCostumes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No costumes available in this category',
                      style: TextStyle(
                        color: _C.grey500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : GridView.builder(
                  key: const Key('costume_catalog_grid'),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredCostumes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.60,
                  ),
                  itemBuilder: (context, index) =>
                      _CatalogProductCard(data: filteredCostumes[index]),
                ),
        );
      },
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  CATALOG PRODUCT CARD (Stateless for performance)
//  Each card: grey bg image, title, series, price, size, condition,
//  availability badge. Taps navigate to DetailCostumePage.
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _CatalogProductCard extends StatelessWidget {
  final CostumeData data;
  const _CatalogProductCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('catalog_card_${data.title}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCostumePage(costumeData: data.toMap()),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Image Canvas: 1:1 Square â”€â”€
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Layer 1: Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox.expand(
                      child: Image.asset(
                        data.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Color(0x000ffbbb),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Layer 3: Status Badge (Left Top)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: data.isReady ? _C.readyGreenBg : _C.rentedRedBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.isReady ? "Ready" : "Rented",
                        style: TextStyle(
                          color: data.isReady ? _C.readyGreen : _C.rentedRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Layer 2: Favorite Icon (Right Top)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        WishlistManager.instance.toggleWishlist(data.title);
                      },
                      child: ValueListenableBuilder<List<String>>(
                        valueListenable: WishlistManager.instance.wishlistNotifier,
                        builder: (context, wishlist, _) {
                          final isLiked = wishlist.contains(data.title);
                          return Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _C.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isLiked ? Colors.red : _C.black,
                              size: 16,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // â”€â”€ Typography Section â”€â”€
          const SizedBox(height: 10),

          // Series/Brand â€” Bold Black
          Text(
            data.series,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _C.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          // Costume Name â€” Dark Grey, 2 lines
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 12,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          // Label: "Lowest Rental Price"
          const Text(
            "Lowest Rental Price",
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 2),

          // Price â€” Bold Black
          Text(
            "Rp ${data.price}",
            style: const TextStyle(
              color: _C.black,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
