import 'package:flutter/material.dart';
import '../models/session.dart';

enum SessionSort {
  recent('Recent activity'),
  created('Newest created'),
  status('Running first'),
  tokens('Most tokens'),
  cost('Highest cost');

  const SessionSort(this.label);
  final String label;
  List<Session> apply(List<Session> rows) {
    if (this == recent) {
      return rows; // Keep the browser's native recent/rank order.
    }
    num? value(Session s) => switch (this) {
      created => s.startedAt,
      status => s.isActive ? 1 : 0,
      tokens => s.totalTokens,
      cost => s.costUsd,
      recent => s.lastActive,
    };
    return [...rows]..sort((a, b) {
      final x = value(a), y = value(b);
      final result = x == null
          ? (y == null ? 0 : 1)
          : y == null
          ? -1
          : y.compareTo(x);
      return result != 0 ? result : b.lastActive.compareTo(a.lastActive);
    });
  }
}

enum SessionGroup {
  standard('Default grouping'),
  status('Group by status'),
  project('Group by project');

  const SessionGroup(this.label);
  final String label;
}

class SessionOrganisationMenu extends StatelessWidget {
  const SessionOrganisationMenu({
    required this.sort,
    required this.group,
    required this.rows,
    required this.details,
    required this.onSort,
    required this.onGroup,
    required this.onDetails,
    this.projects = false,
    super.key,
  });
  final SessionSort sort;
  final SessionGroup group;
  final bool details, projects;
  final List<Session> rows;
  final ValueChanged<SessionSort> onSort;
  final ValueChanged<SessionGroup> onGroup;
  final VoidCallback onDetails;
  @override
  Widget build(BuildContext context) => PopupMenuButton<Object>(
    tooltip: 'Organise chats',
    icon: const Icon(Icons.tune),
    onSelected: (choice) {
      switch (choice) {
        case SessionSort s:
          onSort(s);
        case SessionGroup g:
          onGroup(g);
        default:
          onDetails();
      }
    },
    itemBuilder: (context) => [
      for (final s in SessionSort.values)
        CheckedPopupMenuItem(
          value: s,
          checked: sort == s,
          enabled:
              s == sort ||
              switch (s) {
                SessionSort.tokens => rows.any((r) => r.totalTokens != null),
                SessionSort.cost => rows.any((r) => r.costUsd != null),
                _ => true,
              },
          child: Text(s.label),
        ),
      const PopupMenuDivider(),
      for (final g in SessionGroup.values)
        if (g != SessionGroup.project || projects)
          CheckedPopupMenuItem(
            value: g,
            checked: group == g,
            child: Text(g.label),
          ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: 'details',
        checked: details,
        child: const Text('Show model and usage'),
      ),
    ],
  );
}

String sessionDetails(Session row) => [
  if (row.model.isNotEmpty) row.model,
  if (row.totalTokens case final n?) '$n tokens',
  if (row.costUsd case final c?) '\$${c.toStringAsFixed(4)}',
].join(' · ');
Map<String, List<Session>> labelledGroups(
  Iterable<Session> rows,
  String Function(Session) label,
) {
  final groups = <String, List<Session>>{};
  for (final s in rows) {
    (groups[label(s)] ??= []).add(s);
  }
  return groups;
}
