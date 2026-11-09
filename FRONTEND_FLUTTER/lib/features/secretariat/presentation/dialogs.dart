import 'package:flutter/material.dart';
import 'package:apc_frontend/core/utils/display_formatters.dart';

class InquiryDialog extends StatefulWidget {
  const InquiryDialog({super.key});

  @override
  State<InquiryDialog> createState() => InquiryDialogState();
}

class InquiryDialogState extends State<InquiryDialog> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  String _source = 'walk_in';

  @override
  void dispose() {
    _subject.dispose();
    _contact.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ApcDialog(
    title: 'Nouvelle demande',
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Enregistrer'),
      ),
    ],
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _subject,
            decoration: const InputDecoration(labelText: 'Objet du travail'),
            validator: requiredField,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _contact,
                  decoration: const InputDecoration(
                    labelText: 'Nom du contact',
                  ),
                  validator: requiredField,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone (facultatif)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _source,
            decoration: const InputDecoration(labelText: 'Canal d’arrivée'),
            items: const [
              DropdownMenuItem(value: 'walk_in', child: Text('Guichet')),
              DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
              DropdownMenuItem(value: 'phone', child: Text('Téléphone')),
              DropdownMenuItem(value: 'email', child: Text('Email')),
              DropdownMenuItem(
                value: 'referral',
                child: Text('Recommandation'),
              ),
              DropdownMenuItem(
                value: 'social_media',
                child: Text('Réseaux sociaux'),
              ),
              DropdownMenuItem(value: 'other', child: Text('Autre')),
            ],
            onChanged: (value) => setState(() => _source = value ?? 'walk_in'),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _description,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description du besoin',
            ),
            validator: requiredField,
          ),
        ],
      ),
    ),
  );

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.pop(context, <String, String>{
      'subject': _subject.text.trim(),
      'contact_name': _contact.text.trim(),
      'contact_phone': _phone.text.trim(),
      'description': _description.text.trim(),
      'source': _source,
    });
  }
}

class CustomerDialog extends StatefulWidget {
  const CustomerDialog({super.key});

  @override
  State<CustomerDialog> createState() => CustomerDialogState();
}

class CustomerDialogState extends State<CustomerDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _type = 'individual';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ApcDialog(
    title: 'Ajouter un client',
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () {
          if (!(_form.currentState?.validate() ?? false)) return;
          Navigator.pop(context, {'name': _name.text.trim(), 'type': _type});
        },
        child: const Text('Créer la fiche'),
      ),
    ],
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'individual',
                label: Text('Particulier'),
                icon: Icon(Icons.person_outline),
              ),
              ButtonSegment(
                value: 'company',
                label: Text('Entreprise'),
                icon: Icon(Icons.storefront_outlined),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) =>
                setState(() => _type = selection.first),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(
              labelText: _type == 'company' ? 'Raison sociale' : 'Nom complet',
            ),
            validator: requiredField,
          ),
        ],
      ),
    ),
  );
}

class ApcDialog extends StatelessWidget {
  const ApcDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
  });
  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: const Color(0xFFFFFEFB),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(23, 22, 23, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Fermer',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(spacing: 8, children: actions),
            ),
          ],
        ),
      ),
    ),
  );
}
