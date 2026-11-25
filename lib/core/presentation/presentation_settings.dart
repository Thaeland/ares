import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'imported_theme.dart';
import 'pet_window.dart';
import 'petdex.dart';
import 'presentation_label.dart';
import 'presentation_scope.dart';
import 'radio.dart';
import 'reading_controls.dart';

/// A theme file the panel can parse without touching the platform picker.
typedef PickedThemeFile = ({String name, Uint8List bytes});

/// Appearance, companion, radio and the in-app tour. Both layouts mount this
/// same panel; it uses the surrounding [PresentationHost] when one exists.
class PresentationSettingsPanel extends StatefulWidget {
  const PresentationSettingsPanel({
    super.key,
    required this.preferences,
    this.pickTheme,
    this.pickDraft,
  });

  final SharedPreferences preferences;
  final Future<PickedThemeFile?> Function()? pickTheme;
  final Future<PetDraft?> Function()? pickDraft;

  @override
  State<PresentationSettingsPanel> createState() =>
      _PresentationSettingsPanelState();
}

class _GuideStep {
  const _GuideStep(
    this.id,
    this.en,
    this.ar,
    this.zh,
    this.bodyEn,
    this.bodyAr,
    this.bodyZh,
  );

  final String id;
  final String en;
  final String ar;
  final String zh;
  final String bodyEn;
  final String bodyAr;
  final String bodyZh;
}

const _steps = <_GuideStep>[
  _GuideStep(
    'theme',
    'Imported themes',
    'السمات المستوردة',
    '匯入的佈景主題',
    'Import a VS Code colour theme from a file on this device, then choose which variant to keep.',
    'استورد سمة ألوان من ملف على هذا الجهاز، ثم اختر النسخة التي تريد إبقاءها.',
    '從這台裝置上的檔案匯入 VS Code 色彩佈景主題，再選擇要保留的版本。',
  ),
  _GuideStep(
    'fonts',
    'Reading fonts',
    'خطوط القراءة',
    '閱讀字型',
    'Chat prose and terminal code use separate faces shipped with Ares.',
    'يستخدم نص الدردشة وشفرة الطرفية خطين منفصلين مدمجين مع آريس.',
    '聊天內文和終端機程式碼使用 Ares 內建的不同字型。',
  ),
  _GuideStep(
    'direction',
    'Transcript direction',
    'اتجاه النص',
    '文字方向',
    'Leave this on automatic, or force the transcript left to right or right to left.',
    'اتركه تلقائيًا، أو أجبر نص المحادثة من اليسار أو من اليمين.',
    '保持自動，或強制對話文字由左至右或由右至左。',
  ),
  _GuideStep(
    'pet',
    'Companion',
    'الرفيق',
    '夥伴',
    'The companion is off until you adopt one. Pop-out adds a small composer.',
    'يبقى الرفيق متوقفًا حتى تتبناه. النافذة المنبثقة تضيف مربع كتابة صغيرًا.',
    '領養之前不會顯示夥伴。彈出視窗會附上一個小撰寫框。',
  ),
  _GuideStep(
    'radio',
    'Radio',
    'الراديو',
    '電台',
    'Radio stays off until you enable it. Play is what opens a stream.',
    'يبقى الراديو متوقفًا حتى تفعّله. زر التشغيل هو ما يفتح البث.',
    '啟用之前不會播放電台。按下播放才會開啟串流。',
  ),
];

class _PresentationSettingsPanelState extends State<PresentationSettingsPanel> {
  final _search = TextEditingController();
  final _targets = <String, GlobalKey>{};
  String _query = '';
  int? _tour;
  String? _error;
  var _busy = false;
  var _prepared = false;
  ReadingControls? _ownedReading;
  PetdexController? _ownedPet;
  AresRadio? _ownedRadio;
  late ImportedThemeStore _themes;
  final _dismissedTips = <String>{};

  static const _tipsKey = 'presentation.tips.v1';

  GlobalKey _key(String id) => _targets.putIfAbsent(id, GlobalKey.new);

  ReadingControls get _reading =>
      PresentationScope.maybeOf(context)?.reading ?? _ownedReading!;

  PetdexController get _pet =>
      PresentationScope.maybeOf(context)?.pet ?? _ownedPet!;

  AresRadio get _radio =>
      PresentationScope.maybeOf(context)?.radio ?? _ownedRadio!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prepared) return;
    _prepared = true;
    final host = PresentationScope.maybeOf(context);
    _themes = host?.themes ?? ImportedThemeStore(widget.preferences);
    if (host == null) {
      _ownedReading = ReadingControls(widget.preferences);
      _ownedPet = PetdexController(widget.preferences);
      _ownedRadio = AresRadio.fromPreferences(widget.preferences);
    }
    final saved = widget.preferences.getStringList(_tipsKey);
    if (saved != null) _dismissedTips.addAll(saved);
  }

  @override
  void dispose() {
    _search.dispose();
    _ownedReading?.dispose();
    _ownedPet?.dispose();
    _ownedRadio?.dispose();
    super.dispose();
  }

  String _t(String en, String ar, String zh) =>
      presentationLabel(context, en, ar, zh);

  bool _visible(_GuideStep step) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    return [
      step.en,
      step.ar,
      step.zh,
      step.bodyEn,
      step.bodyAr,
      step.bodyZh,
    ].any((text) => text.toLowerCase().contains(query));
  }

  Future<void> _jump(_GuideStep step) async {
    setState(() {
      _query = '';
      _search.clear();
    });
    await Future<void>.delayed(Duration.zero);
    final target = _key(step.id).currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        alignment: 0.2,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  void _startTour() {
    setState(() {
      _query = '';
      _search.clear();
      _tour = 0;
    });
    _revealTour();
  }

  Future<void> _revealTour() async {
    final index = _tour;
    if (index == null) return;
    await Future<void>.delayed(Duration.zero);
    final target = _key(_steps[index].id).currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(target, alignment: 0.15);
    }
  }

  void _moveTour(int delta) {
    final index = _tour;
    if (index == null) return;
    final next = index + delta;
    if (next < 0 || next >= _steps.length) {
      setState(() => _tour = null);
      return;
    }
    setState(() => _tour = next);
    _revealTour();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is FormatException
            ? error.message
            : _t(
                'Could not save this change.',
                'تعذّر حفظ هذا التغيير.',
                '無法儲存這項變更。',
              );
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<List<ImportedTheme>?> _loadTheme() async {
    final injected = widget.pickTheme;
    if (injected != null) {
      final file = await injected();
      if (file == null) return null;
      return ImportedThemeParser.parse(file.name, file.bytes);
    }
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['vsix', 'json', 'jsonc'],
      withData: false,
      withReadStream: true,
    );
    if (picked == null || picked.files.isEmpty) return null;
    final file = picked.files.single;
    final stream = file.readStream;
    if (stream == null) {
      throw const FormatException('Choose a .vsix, .json or .jsonc theme.');
    }
    return ImportedThemeParser.parseStream(
      file.name,
      stream,
      declaredSize: file.size,
    );
  }

  Future<void> _import() => _run(() async {
    final variants = await _loadTheme();
    if (variants == null || !mounted) return;
    final chosen = await showDialog<ImportedTheme>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(_t('Keep which theme?', 'أي سمة نُبقي؟', '要保留哪個佈景主題？')),
        children: [
          for (final theme in variants)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, theme),
              child: Text('${theme.label} · ${theme.brightness.name}'),
            ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    final host = PresentationScope.maybeOf(context);
    await _themes.save(chosen);
    host?.themeChanged();
    if (mounted) setState(() {});
  });

  void _dismissTip(String id) {
    setState(() => _dismissedTips.add(id));
    unawaited(
      widget.preferences.setStringList(_tipsKey, _dismissedTips.toList()),
    );
  }

  void _restoreTips() {
    setState(_dismissedTips.clear);
    unawaited(widget.preferences.remove(_tipsKey));
  }

  Widget _section(String id, Widget child) {
    final active = _tour != null && _steps[_tour!].id == id;
    final step = active ? _steps[_tour!] : null;
    return Container(
      key: _key(id),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          if (step != null) ...[
            const SizedBox(height: 8),
            Text(
              _t(step.en, step.ar, step.zh),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(_t(step.bodyEn, step.bodyAr, step.bodyZh)),
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => _moveTour(-1),
                  child: Text(_t('Back', 'رجوع', '上一步')),
                ),
                TextButton(
                  onPressed: () => _moveTour(1),
                  child: Text(
                    _tour == _steps.length - 1
                        ? _t('Finish', 'إنهاء', '完成')
                        : _t('Next', 'التالي', '下一步'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _tour = null),
                  child: Text(_t('Close tour', 'إغلاق الجولة', '關閉導覽')),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tip(String id, String en, String ar, String zh) {
    if (_dismissedTips.contains(id)) return const SizedBox.shrink();
    return MaterialBanner(
      content: Text(_t(en, ar, zh)),
      actions: [
        TextButton(
          onPressed: () => _dismissTip(id),
          child: Text(_t('Dismiss tip', 'إخفاء التلميح', '關閉提示')),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_prepared) return const SizedBox.shrink();
    final library = _themes.read();
    final matches = _steps.where(_visible).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const ValueKey('presentation-search'),
          controller: _search,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            labelText: _t('Search settings', 'البحث في الإعدادات', '搜尋設定'),
          ),
        ),
        if (_query.trim().isNotEmpty)
          for (final step in matches)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_t(step.en, step.ar, step.zh)),
              trailing: Text(_t('Show', 'إظهار', '顯示')),
              onTap: () => _jump(step),
            ),
        if (_query.trim().isNotEmpty && matches.isEmpty)
          Text(_t('No matching setting.', 'لا يوجد إعداد مطابق.', '找不到相符的設定。')),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              key: const ValueKey('presentation-replay-tour'),
              onPressed: _startTour,
              icon: const Icon(Icons.tour_outlined),
              label: Text(_t('Replay tour', 'إعادة الجولة', '再看一次導覽')),
            ),
            TextButton(
              onPressed: _restoreTips,
              child: Text(
                _t('Show tips again', 'أظهر التلميحات مجددًا', '再次顯示提示'),
              ),
            ),
          ],
        ),
        _tip(
          'theme',
          'Imported themes replace the built-in palette until you clear the selection. Only the colours are kept.',
          'تحل السمات المستوردة محل لوحة الألوان المدمجة حتى تلغي الاختيار. تُحفظ الألوان فقط.',
          '匯入的佈景主題會取代內建配色，直到你取消選擇。只會保留色彩。',
        ),
        if (_visible(_steps[0])) _section('theme', _themeSection(library)),
        if (_visible(_steps[1])) _section('fonts', _fontSection()),
        if (_visible(_steps[2])) _section('direction', _directionSection()),
        _section('reading', _readingToggles()),
        _section(
          'window',
          Text(
            _t(
              'Window translucency is not available on this host. Linux cannot provide it, and the Apple and Windows runners paint an opaque Flutter view.',
              'شفافية النافذة غير متاحة على هذا الجهاز. لا يدعمها لينكس، وترسم إصدارات آبل وويندوز نافذة Flutter معتمة.',
              '此主機無法使用視窗透明度。Linux 不支援，Apple 與 Windows 執行程式繪製的是不透明的 Flutter 視窗。',
            ),
          ),
        ),
        if (_visible(_steps[3])) _section('pet', _petSection()),
        if (_visible(_steps[4]))
          _section('radio', AresRadioSettingsBody(radio: _radio)),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }

  Widget _themeSection(ImportedThemeLibrary library) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('Imported themes', 'السمات المستوردة', '匯入的佈景主題'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        OutlinedButton.icon(
          key: const ValueKey('presentation-import-theme'),
          onPressed: _busy ? null : _import,
          icon: const Icon(Icons.palette_outlined),
          label: Text(_t('Import theme file', 'استيراد ملف سمة', '匯入佈景主題檔')),
        ),
        for (final theme in library.themes)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(theme.label),
            subtitle: Text(theme.source),
            leading: Icon(
              library.selectedId == theme.id
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
            ),
            onTap: _busy
                ? null
                : () {
                    final host = PresentationScope.maybeOf(context);
                    final id = theme.id;
                    final clear = library.selectedId == id;
                    _run(() async {
                      await _themes.select(clear ? null : id);
                      host?.themeChanged();
                    });
                  },
            trailing: IconButton(
              tooltip: _t('Remove theme', 'حذف السمة', '移除佈景主題'),
              onPressed: _busy
                  ? null
                  : () {
                      final host = PresentationScope.maybeOf(context);
                      final id = theme.id;
                      _run(() async {
                        await _themes.remove(id);
                        host?.themeChanged();
                      });
                    },
              icon: const Icon(Icons.delete_outline),
            ),
          ),
      ],
    );
  }

  Widget _fontSection() {
    final reading = _reading;
    return ListenableBuilder(
      listenable: reading,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('Chat font', 'خط الدردشة', '聊天字型'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          DropdownButton<AresTypeface>(
            key: const ValueKey('presentation-chat-font'),
            isExpanded: true,
            value: reading.chatFont,
            items: [
              for (final face in AresTypeface.chatChoices)
                DropdownMenuItem(value: face, child: Text(_face(face))),
            ],
            onChanged: _busy
                ? null
                : (face) {
                    if (face != null) _run(() => reading.setChatFont(face));
                  },
          ),
          Text(
            _t('Terminal font', 'خط الطرفية', '終端機字型'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          DropdownButton<AresTypeface>(
            key: const ValueKey('presentation-terminal-font'),
            isExpanded: true,
            value: reading.terminalFont,
            items: [
              for (final face in AresTypeface.terminalChoices)
                DropdownMenuItem(value: face, child: Text(_face(face))),
            ],
            onChanged: _busy
                ? null
                : (face) {
                    if (face != null) {
                      _run(() => reading.setTerminalFont(face));
                    }
                  },
          ),
        ],
      ),
    );
  }

  String _face(AresTypeface face) => switch (face) {
    AresTypeface.platform => _t('Platform', 'خط الجهاز', '系統字型'),
    AresTypeface.geist => 'Geist',
    AresTypeface.geistMono => 'Geist Mono',
    AresTypeface.cinzel => 'Cinzel',
  };

  Widget _directionSection() {
    final reading = _reading;
    return ListenableBuilder(
      listenable: reading,
      builder: (context, _) => Column(
        children: [
          DropdownButton<TranscriptDirection>(
            key: const ValueKey('presentation-direction'),
            isExpanded: true,
            value: reading.direction,
            items: [
              DropdownMenuItem(
                value: TranscriptDirection.automatic,
                child: Text(_t('Automatic', 'تلقائي', '自動')),
              ),
              DropdownMenuItem(
                value: TranscriptDirection.leftToRight,
                child: Text(
                  _t('Force left to right', 'إجبار من اليسار', '強制由左至右'),
                ),
              ),
              DropdownMenuItem(
                value: TranscriptDirection.rightToLeft,
                child: Text(
                  _t('Force right to left', 'إجبار من اليمين', '強制由右至左'),
                ),
              ),
            ],
            onChanged: _busy
                ? null
                : (value) {
                    if (value != null) _run(() => reading.setDirection(value));
                  },
          ),
          Text(_t('User bubble opacity', 'شفافية فقاعة رسائلك', '自己的訊息氣泡透明度')),
          Semantics(
            label: _t(
              'User bubble opacity',
              'شفافية فقاعة رسائلك',
              '自己的訊息氣泡透明度',
            ),
            child: Slider(
              key: const ValueKey('presentation-bubble-opacity'),
              min: ReadingControls.minBubbleOpacity,
              max: 1,
              value: reading.bubbleOpacity,
              onChanged: _busy
                  ? null
                  : (value) => _run(() => reading.setBubbleOpacity(value)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readingToggles() {
    final reading = _reading;
    return ListenableBuilder(
      listenable: reading,
      builder: (context, _) => Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            key: const ValueKey('presentation-embeds'),
            title: Text(
              _t('External embeds', 'المحتوى المضمّن الخارجي', '外部嵌入內容'),
            ),
            subtitle: Text(
              _t(
                'Show a card for https images. Nothing is downloaded until you open it.',
                'أظهر بطاقة لصور https. لا يُنزَّل شيء حتى تفتحه.',
                '為 https 圖片顯示卡片。開啟之前不會下載。',
              ),
            ),
            value: reading.externalEmbeds,
            onChanged: _busy
                ? null
                : (value) => _run(() => reading.setExternalEmbeds(value)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            key: const ValueKey('presentation-reactions'),
            title: Text(_t('Emoji reactions', 'تفاعلات الإيموجي', '表情回應')),
            value: reading.emojiReactions,
            onChanged: _busy
                ? null
                : (value) => _run(() => reading.setEmojiReactions(value)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            key: const ValueKey('presentation-hearts'),
            title: Text(_t('Celebration hearts', 'قلوب الاحتفال', '慶祝愛心')),
            subtitle: Text(
              _t(
                'A heart plays when a reply arrives while you were away.',
                'يظهر قلب عندما يصل رد وأنت بعيد.',
                '你離開時若有回覆送達，會播放一顆愛心。',
              ),
            ),
            value: reading.celebrationHearts,
            onChanged: _busy
                ? null
                : (value) => _run(() => reading.setCelebrationHearts(value)),
          ),
        ],
      ),
    );
  }

  Widget _petSection() {
    final pet = _pet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tip(
          'pet',
          'The companion stores one small portrait on this device. It does not upload the picture you hatch from.',
          'يحفظ الرفيق صورة صغيرة واحدة على هذا الجهاز. لا يرفع الصورة التي تفقس منها.',
          '夥伴只在這台裝置上儲存一張小肖像，不會上傳你用來孵化的圖片。',
        ),
        PetdexSettings(
          controller: pet,
          pickDraft: widget.pickDraft ?? PetDraft.pick,
        ),
        OutlinedButton.icon(
          key: const ValueKey('presentation-pet-popout'),
          onPressed: () => openPetCompanion(context, pet),
          icon: const Icon(Icons.open_in_new),
          label: Text(
            _t('Pop out companion', 'افتح الرفيق في نافذة', '將夥伴彈出視窗'),
          ),
        ),
      ],
    );
  }
}
