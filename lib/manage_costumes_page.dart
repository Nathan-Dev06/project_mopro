import 'package:flutter/material.dart';
import 'home_page.dart';
import 'costume_manager.dart';

class ManageCostumesPage extends StatefulWidget {
  const ManageCostumesPage({super.key});

  @override
  State<ManageCostumesPage> createState() =>
      _ManageCostumesPageState();
}

class _ManageCostumesPageState
    extends State<ManageCostumesPage> {

  void _deleteCostume(int index) {
    final costumes =
        List<CostumeData>.from(
      CostumeManager
          .instance
          .costumesNotifier
          .value,
    );

    costumes.removeAt(index);

    CostumeManager
        .instance
        .costumesNotifier
        .value = costumes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Costumes',
        ),
      ),
      body:
          ValueListenableBuilder<
              List<CostumeData>>(
        valueListenable:
            CostumeManager
                .instance
                .costumesNotifier,
        builder:
            (context, costumes, _) {

          return ListView.builder(
            itemCount:
                costumes.length,
            itemBuilder:
                (context, index) {

              final costume =
                  costumes[index];

              return Card(
                margin:
                    const EdgeInsets.all(
                        10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      '${index + 1}',
                    ),
                  ),
                  title: Text(
                    costume.title,
                  ),
                  subtitle: Text(
                    '${costume.series}\nRp ${costume.price}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [

                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _deleteCostume(
                              index);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}