import 'package:flutter/material.dart';

/// Always use the workspace navigator: an account change removes both the
/// owner and any unfinished choice, even if IDs are reused by the new owner.
Future<T?> pickWorkspaceItem<T>(
  BuildContext context,
  String title,
  List<({T value, String label, String detail})> items,
) {
  var query = '';
  return showDialog<T>(
    context: context,
    useRootNavigator: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final matches = items
            .where(
              (e) => '${e.label} ${e.detail}'.toLowerCase().contains(query),
            )
            .toList();
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 440,
            height: 340,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Filter'),
                  onChanged: (s) => setState(() => query = s.toLowerCase()),
                ),
                Expanded(
                  child: matches.isEmpty
                      ? const Center(child: Text('No matching items.'))
                      : ListView.builder(
                          itemCount: matches.length,
                          itemBuilder: (context, i) {
                            final item = matches[i];
                            return ListTile(
                              title: Text(item.label),
                              subtitle: item.detail.isEmpty
                                  ? null
                                  : Text(item.detail),
                              onTap: () => Navigator.pop(context, item.value),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ),
  );
}

Future<String?> nameWorkspaceLayout(BuildContext context) {
  var name = '';
  return showDialog<String>(
    context: context,
    useRootNavigator: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Save layout'),
        content: TextField(
          autofocus: true,
          maxLength: 64,
          decoration: const InputDecoration(labelText: 'Layout name'),
          onChanged: (s) => setState(() => name = s.trim()),
          onSubmitted: (_) {
            if (name.isNotEmpty) Navigator.pop(context, name);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: name.isEmpty ? null : () => Navigator.pop(context, name),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
