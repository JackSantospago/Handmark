import 'package:flutter/material.dart';

import '../../core/requests.dart';
import '../browse/browse_screen.dart';
import '../certify/certification_screen.dart';
import '../invite/invite_screen.dart';
import '../maker/maker_screen.dart';
import '../piece/piece_screen.dart';
import '../request/request_status_screen.dart';

/// Bottom navigation, always visible: Collection · Makers · Requests · Invite.
/// Piece, maker and request pages are pushed on top.
/// [openPieceId] opens a piece on start (the preview's ?piece= option).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialTab = 0, this.openPieceId, this.openCertification = false});
  final int initialTab;
  final String? openPieceId;

  /// Open "How we certify" on start (the preview's ?page=certification option).
  final bool openCertification;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _tab = widget.initialTab;

  @override
  void initState() {
    super.initState();
    if (widget.openCertification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) openCertification(context);
      });
    }
    final id = widget.openPieceId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final p = context.catalog.piece(id);
        if (p != null && mounted) openPiece(context, p);
      });
    }
  }

  void _goTo(int tab) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final waiting = context.requests.items
        .where((r) => r.stage == RequestStage.awaitingMaker || r.stage == RequestStage.confirmed)
        .length;
    final Widget page = switch (_tab) {
      1 => const MakersScreen(),
      2 => RequestsScreen(onBrowse: () => _goTo(0)),
      3 => const InviteScreen(),
      _ => const BrowseScreen(),
    };

    return Scaffold(
      body: KeyedSubtree(key: ValueKey(_tab), child: page),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: c.outlineVariant))),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _goTo,
          destinations: [
            const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Collection'),
            const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Makers'),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: waiting > 0,
                backgroundColor: c.secondary,
                smallSize: 7,
                child: const Icon(Icons.receipt_long_outlined),
              ),
              selectedIcon: const Icon(Icons.receipt_long),
              label: 'Requests',
            ),
            const NavigationDestination(icon: Icon(Icons.mail_outline), selectedIcon: Icon(Icons.mail), label: 'Invite'),
          ],
        ),
      ),
    );
  }
}
