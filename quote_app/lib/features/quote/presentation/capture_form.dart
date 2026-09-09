import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class CaptureForm extends StatefulWidget {
  const CaptureForm({super.key, required this.onSubmit});
  final void Function(QuoteRequest) onSubmit;

  @override
  State<CaptureForm> createState() => _CaptureFormState();
}

class _CaptureFormState extends State<CaptureForm> {
  final _formKey = GlobalKey<FormState>();
  final _makeCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  Cover _cover = Cover.comprehensive;
  DateTime? _licenceDate;
  bool _autovalidate = false;

  @override
  void dispose() {
    _makeCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = true);
      return;
    }
    final year = int.parse(_yearCtrl.text);
    final licenceYear = _licenceDate?.year ?? DateTime.now().year;
    final age = DateTime.now().year - licenceYear + 18;
    widget.onSubmit(
      QuoteRequest(make: _makeCtrl.text.trim(), year: year, driverAge: age, cover: _cover),
    );
  }

  Future<void> _reset() async {
    final hasData = _makeCtrl.text.isNotEmpty || _yearCtrl.text.isNotEmpty || _licenceDate != null;
    if (hasData) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset form?'),
          content: const Text('This clears everything you have entered.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
          ],
        ),
      );
      if (!context.mounted || confirmed != true) return;
    }
    _formKey.currentState!.reset();
    _makeCtrl.clear();
    _yearCtrl.clear();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    autovalidateMode: _autovalidate
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled,
    child: _fields(context),
  );

  Widget _fields(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextFormField(
        controller: _makeCtrl,
        decoration: const InputDecoration(labelText: 'Vehicle make', hintText: 'e.g. VW'),
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Make is required' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _yearCtrl,
        decoration: const InputDecoration(labelText: 'Year'),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        validator: (v) {
          final y = int.tryParse(v ?? '');
          if (y == null) return 'Enter a 4-digit year';
          if (y < 1990 || y > DateTime.now().year) {
            return 'Year must be 1990-${DateTime.now().year}';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      FormField<Cover>(
        initialValue: _cover,
        builder: (state) => InputDecorator(
          decoration: InputDecoration(labelText: 'Cover', errorText: state.errorText),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final c in Cover.values)
                _CoverCard(
                  cover: c,
                  selected: c == _cover,
                  onTap: () {
                    setState(() => _cover = c);
                    state.didChange(c);
                  },
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      _LicenceDateField(value: _licenceDate, onChanged: (d) => setState(() => _licenceDate = d)),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.calculate),
        label: const Text('Get quote'),
      ),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: _reset, child: const Text('Reset')),
    ],
  );
}

class _LicenceDateField extends StatelessWidget {
  const _LicenceDateField({required this.value, required this.onChanged});
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? 'Select date' : DateFormat.yMMMd('en_ZA').format(value!);
    return FormField<DateTime>(
      initialValue: value,
      validator: (d) => d == null ? 'Licence date is required' : null,
      builder: (state) => InputDecorator(
        decoration: InputDecoration(
          labelText: 'Licence issue date',
          errorText: state.errorText,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime(now.year - 5),
              firstDate: DateTime(1950),
              lastDate: now,
            );
            if (picked != null) {
              state.didChange(picked);
              onChanged(picked);
            }
          },
          child: Text(text),
        ),
      ),
    );
  }
}

class _CoverCard extends StatelessWidget {
  const _CoverCard({required this.cover, required this.selected, required this.onTap});
  final Cover cover;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: selected ? scheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              cover.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ),
    );
  }
}
