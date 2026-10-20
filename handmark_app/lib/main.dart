// The app without the phone frame. There is no backend yet, so it runs on the
// same demo catalog as the preview (lib/main_preview.dart).
import 'package:flutter/material.dart';

import 'core/app_settings.dart';
import 'core/requests.dart';
import 'frontend/shared/theme.dart';
import 'frontend/shell/home_shell.dart';
import 'preview/fake_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings();
  await settings.load();
  final catalog = fakeCatalog();
  runApp(SettingsScope(
    settings: settings,
    child: HandmarkScope(
      catalog: catalog,
      requests: fakeRequests(catalog, seed: false),
      child: MaterialApp(
        title: 'Handmark',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const HomeShell(),
      ),
    ),
  ));
}
