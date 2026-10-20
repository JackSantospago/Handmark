import 'package:flutter/material.dart';

import '../../core/app_settings.dart';
import '../../core/config.dart';
import '../certify/certification_screen.dart';
import '../shared/ui.dart';

/// Early access: email capture for buyers who want an invitation.
class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final _email = TextEditingController();
  String? _error;

  static final _valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final e = _email.text.trim();
    if (!_valid.hasMatch(e)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _error = null);
    context.settings.setInviteEmail(e); // demo: stored on this device only, sent nowhere
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final invited = context.settings.inviteEmail;

    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 40), children: [
        const PageHeader(
          eyebrow: 'Early access',
          title: 'Handmark opens by invitation.',
          subtitle: 'We are admitting a small number of collectors each month, in step with the '
              'number of makers we can verify. Leave your email and we will write when there is a place.',
        ),
        if (invited == null) ...[
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(labelText: 'Email address', errorText: _error),
          ),
          const SizedBox(height: 14),
          FilledButton(onPressed: _submit, child: const Text('Request an invite')),
          const SizedBox(height: 10),
          Text('One email when your invitation is ready. Nothing else.', style: t.bodySmall, textAlign: TextAlign.center),
        ] else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border.all(color: c.outline)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.check, color: c.secondary),
              const SizedBox(height: 12),
              Text('You are on the list.', style: t.titleLarge),
              const SizedBox(height: 8),
              Text('We will write to $invited when your invitation is ready.', style: t.bodyMedium),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.settings.setInviteEmail(null),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('Use a different email'),
              ),
            ]),
          ),
        const SizedBox(height: 48),
        const SectionLabel('What members get'),
        GroupCard(children: [
          RowTile(
            icon: Icons.verified_outlined,
            title: 'Verified in person',
            subtitle: 'Every maker visited, every piece documented before it is listed. See how we certify.',
            onTap: () => openCertification(context),
          ),
          const RowTile(
            icon: Icons.schedule_outlined,
            title: 'Held while you decide',
            subtitle: 'Request a piece and it is reserved while the maker confirms. No payment until then.',
          ),
          RowTile(
            icon: Icons.local_shipping_outlined,
            title: 'Insured delivery, easy returns',
            subtitle: 'Crated where needed. Returns within $kReturnDays days.',
          ),
        ]),
      ]),
    );
  }
}
