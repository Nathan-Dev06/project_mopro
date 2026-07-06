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

  void addCostume(CostumeData costume) {
    final costumes = List<CostumeData>.from(costumesNotifier.value);
    costumes.add(costume);
    costumesNotifier.value = costumes;
  }

  void decrementStock(String title, String size) {
    final costumes = List<CostumeData>.from(costumesNotifier.value);
    final index = costumes.indexWhere((c) => c.title.trim().toLowerCase() == title.trim().toLowerCase());
    if (index != -1) {
      final original = costumes[index];
      final currentStocks = Map<String, int>.from(original.activeStocks);
      if (currentStocks.containsKey(size)) {
        final currentStock = currentStocks[size] ?? 0;
        if (currentStock > 0) {
          currentStocks[size] = currentStock - 1;
          costumes[index] = CostumeData(
            title: original.title,
            series: original.series,
            price: original.price,
            condition: original.condition,
            image: original.image,
            include: original.include,
            size: original.size,
            isReady: original.isReady,
            category: original.category,
            rating: original.rating,
            reviewCount: original.reviewCount,
            sizeStocks: currentStocks,
          );
          costumesNotifier.value = costumes;
        }
      }
    }
  }
}