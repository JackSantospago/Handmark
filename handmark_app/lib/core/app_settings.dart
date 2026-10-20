import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

/// On-device preferences (just the early-access email for now), saved as a
/// small JSON file next to the other app data. On the web there are no files,
/// so the value lives for the session.
class AppSettings extends ChangeNotifier {
  String? _inviteEmail;

  /// The email the buyer asked to be invited with, if any.
  String? get inviteEmail => _inviteEmail;

  static Future<File> _file() async =>
      File('${(await getApplicationDocumentsDirectory()).path}/settings.json');

  Future<void> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return;
      final j = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      _inviteEmail = j['inviteEmail'] as String?;
    } catch (_) {/* keep defaults */}
  }

  Future<void> setInviteEmail(String? email) async {
    if (email == _inviteEmail) return;
    _inviteEmail = email;
    notifyListeners();
    try {
      await (await _file()).writeAsString(jsonEncode({'inviteEmail': email}));
    } catch (_) {/* the choice still applies for this session */}
  }
}

/// Makes [AppSettings] available below it; widgets that read it rebuild when
/// it changes.
class SettingsScope extends InheritedNotifier<AppSettings> {
  const SettingsScope({super.key, required AppSettings settings, required super.child})
      : super(notifier: settings);

  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}

extension SettingsContext on BuildContext {
  /// `context.settings.inviteEmail`
  AppSettings get settings => SettingsScope.of(this);
}
