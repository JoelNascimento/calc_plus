import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../models/calculation.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    var historyBox = Hive.box<Calculation>('history');

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: ValueListenableBuilder(
        valueListenable: historyBox.listenable(),
        builder: (context, Box<Calculation> box, _) {
          if (box.isEmpty) return const Center(child: Text('Nenhum histórico.'));
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final item = box.getAt(index); // já é um Calculation
              if (item == null) return const SizedBox(); // segurança
              return ListTile(
                title: Text(item.expression),
                subtitle: Text('= ${item.result}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.delete),
        onPressed: () => historyBox.clear(),
      ),
    );
  }
}
