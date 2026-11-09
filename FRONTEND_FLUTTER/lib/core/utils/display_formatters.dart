String textOrFallback(dynamic value, String fallback) =>
    value == null || '$value'.trim().isEmpty ? fallback : '$value';
String initialsFor(dynamic value) {
  final parts = textOrFallback(value, 'APC').trim().split(RegExp(r'\s+'));
  return parts
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
      .join();
}

String formatMoney(dynamic value) {
  final amount = value is num ? value : num.tryParse('$value') ?? 0;
  return amount.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );
}

String statusLabel(String status) => switch (status) {
  'new' => 'NOUVELLE',
  'qualified' => 'QUALIFIÉE',
  'quote_sent' => 'DEVIS ENVOYÉ',
  'refused' => 'REFUSÉE',
  'converted' => 'CONVERTIE',
  _ => status.toUpperCase(),
};

String? statusCode(String label) => switch (label) {
  'Nouvelles' => 'new',
  'Qualifiées' => 'qualified',
  'Devis envoyés' => 'quote_sent',
  'Refusées' => 'refused',
  _ => null,
};

String? requiredField(String? value) =>
    value == null || value.trim().isEmpty ? 'Ce champ est requis.' : null;
