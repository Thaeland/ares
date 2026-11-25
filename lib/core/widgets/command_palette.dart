/// App-wide command palette overlay.
///
/// Rendered by both shells (Classic and NextGen) against the same widget so
/// behavior is identical. On wide screens it presents as a centered dialog;
/// on narrow panes (< 480 px) it presents as a full-screen takeover — the
/// narrow-device alternative is the same code path, not a separate widget.
///
/// The palette never executes a command on open; selection is reported via
/// [onSelected]. Actions are supplied by the caller.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One selectable action in the palette.
class PaletteAction {
  const PaletteAction({
    required this.id,
    required this.label,
    required this.icon,
    this.hint,
    this.keywords = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final String? hint;
  final List<String> keywords;
}

/// Shared command palette. Render-only; selection and navigation are delegated.
class CommandPalette extends StatefulWidget {
  const CommandPalette({
    required this.actions,
    required this.onSelected,
    super.key,
  });

  final List<PaletteAction> actions;
  final ValueChanged<PaletteAction> onSelected;

  @override
  State<CommandPalette> createState() => CommandPaletteState();
}

class CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _controller = TextEditingController();
  List<PaletteAction> _filtered = const [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filter('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filter(String text) {
    final query = text.trim().toLowerCase();
    if (query.isEmpty) {
      _filtered = List<PaletteAction>.of(widget.actions);
    } else {
      _filtered = widget.actions.where((action) {
        final haystack = <String>[action.label, ...action.keywords]
            .join(' ')
            .toLowerCase();
        return haystack.contains(query);
      }).toList();
    }
    _selectedIndex = _selectedIndex.clamp(0, _filtered.length - 1);
    setState(() {});
  }

  void _close() {
    Navigator.of(context).pop();
  }

  void _select(PaletteAction action) {
    _close();
    widget.onSelected(action);
  }

  void _selectCurrent() {
    if (_filtered.isEmpty) return;
    _select(_filtered[_selectedIndex]);
  }

  void _moveSelection(int delta) {
    if (_filtered.isEmpty) return;
    final next = (_selectedIndex + delta) % _filtered.length;
    setState(() => _selectedIndex = next < 0
        ? next + _filtered.length
        : next);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _moveSelection(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _moveSelection(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
        _selectCurrent();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        _close();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNarrow = MediaQuery.of(context).size.width < 480;
    final body = _buildBody(theme);
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKey,
      child: isNarrow
          ? Scaffold(backgroundColor: theme.colorScheme.surface, body: body)
          : Dialog(
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: body,
                ),
              ),
            ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: _filter,
            decoration: InputDecoration(
              hintText: 'Type to filter actions…',
              prefixIcon: const Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 12,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 320,
          child: _filtered.isEmpty
              ? Center(child: Text('No matching actions'))
              : ListView.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final action = _filtered[index];
                    final selected = index == _selectedIndex;
                    return Material(
                      color: selected
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.transparent,
                      child: InkWell(
                        onTap: () => _select(action),
                        onHover: (hovered) {
                          if (hovered) {
                            setState(() => _selectedIndex = index);
                          }
                        },
                        child: ListTile(
                          leading: Icon(action.icon),
                          title: Text(action.label),
                          subtitle: action.hint == null
                              ? null
                              : Text(action.hint!),
                          trailing: selected
                              ? const Icon(Icons.arrow_forward)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          child: Wrap(
            spacing: 10,
            runSpacing: 2,
            children: const [
              Text('↑↓ to move', style: TextStyle(fontSize: 12)),
              Text('Enter to run', style: TextStyle(fontSize: 12)),
              Text('Esc to close', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
