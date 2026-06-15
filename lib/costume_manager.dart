import 'package:flutter/foundation.dart';
import 'home_page.dart';

class CostumeManager {
  CostumeManager._();

  static final CostumeManager instance =
      CostumeManager._();

  final ValueNotifier<List<CostumeData>>
      costumesNotifier =
      ValueNotifier<List<CostumeData>>(
    List<CostumeData>.from(kCostumes),
  );
}