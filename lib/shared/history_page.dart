import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List history;
  final Function(dynamic) onSelect;
  final String title;

  const HistoryPage({
    required this.history,
    required this.onSelect,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: history.isEmpty
          ? Center(child: Text("Belum ada history"))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final h = history[index];

                return ListTile(
                  leading: Icon(Icons.history),
                  title: Text(h.toString()),
                  onTap: () {
                    onSelect(h);
                    Navigator.pop(context);
                  },
                );
              },
            ),
    );
  }
}