import 'package:flutter/foundation.dart';
import 'package:project_mopro/features/customer/pages/home_page.dart';

class CostumeManager {
  CostumeManager._();

  static final CostumeManager instance =
      CostumeManager._();

  final ValueNotifier<List<CostumeData>>
      costumesNotifier =
      ValueNotifier<List<CostumeData>>(
    List<CostumeData>.from(kCostumes),
  );

  void updateCostume(int index, CostumeData newCostume) {
    final costumes = List<CostumeData>.from(costumesNotifier.value);
    costumes[index] = newCostume;
    costumesNotifier.value = costumes;
  }
}