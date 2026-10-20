// UI preview: the real screens on fake data, drawn inside a phone frame
// (iPhone / small Android), so it runs in Chrome with hot reload:
//   flutter run -d chrome -t lib/main_preview.dart
// URL options open a given screen, e.g. http://localhost:8080/?tab=requests&theme=dark
// (all options: lib/preview/preview_options.dart).
import 'package:flutter/material.dart';

import 'core/app_settings.dart';
import 'core/requests.dart';
import 'frontend/shared/theme.dart';
import 'frontend/shell/home_shell.dart';
import 'preview/fake_data.dart';
import 'preview/phone_frame.dart';
import 'preview/preview_options.dart';

/// Light / dark switch in the frame's toolbar.
final _themeMode = ValueNotifier(PreviewOptions.theme);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings();
  await settings.load(); // no files on the web: stays in memory
  runApp(PreviewApp(settings: settings));
}

class PreviewApp extends StatefulWidget {
  const PreviewApp({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<PreviewApp> createState() => _PreviewAppState();
}

class _PreviewAppState extends State<PreviewApp> {
  final _catalog = fakeCatalog();
  late final _requests = fakeRequests(_catalog, seed: PreviewOptions.seedRequest);

  @override
  Widget build(BuildContext context) => SettingsScope(
        settings: widget.settings,
        child: HandmarkScope(
          catalog: _catalog,
          requests: _requests,
          child: ValueListenableBuilder(
            valueListenable: _themeMode,
            builder: (context, mode, _) => MaterialApp(
              title: 'Handmark (preview)',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: mode,
              builder: PreviewOptions.phoneFrame ? (context, child) => PhoneFrame(themeMode: _themeMode, child: child!) : null,
              home: HomeShell(
                initialTab: PreviewOptions.tab,
                openPieceId: PreviewOptions.piece,
                openCertification: PreviewOptions.certification,
              ),
            ),
          ),
        ),
      );
}
