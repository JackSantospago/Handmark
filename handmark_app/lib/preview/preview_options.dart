import 'package:flutter/material.dart';

/// Preview options, read from the page URL so a link can open a given screen:
///   http://localhost:8080/?tab=requests&theme=dark&device=android
///   tab       collection | makers | requests | invite
///   piece     id    open a piece on start, e.g. fjord-chair, moon-jar, signet
///   page      certification  (open "How we certify" on start)
///   requests  none  (start with no demo request waiting on a maker)
///   theme     light | dark       device  iphone | android
///   frame     off  (fill the window, no phone)
abstract final class PreviewOptions {
  static final Map<String, String> _q = Uri.base.queryParameters;

  static const _tabs = ['collection', 'makers', 'requests', 'invite'];
  static int get tab => _tabs.indexOf(_q['tab'] ?? 'collection').clamp(0, _tabs.length - 1);

  static String? get piece => _q['piece'];

  static bool get certification => _q['page'] == 'certification';

  static bool get seedRequest => _q['requests'] != 'none';

  static bool get phoneFrame =>
      _q['frame'] != 'off' && const bool.fromEnvironment('PHONE_FRAME', defaultValue: true);

  // Light by default: the gallery look is designed light-first.
  static ThemeMode get theme => switch (_q['theme']) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };

  static int get device => switch (_q['device']) {
        'android' => 1,
        _ => 0,
      };
}
