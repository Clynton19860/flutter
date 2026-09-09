import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  var _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _makeCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    final year = int.parse(_yearCtrl.text);
    final licenceYear = _licenceDate?.year ?? DateTime.now().year;
    final age = DateTime.now().year - licenceYear + 18;
    widget.onSubmit(
      QuoteRequest(
        make: _makeCtrl.text.trim(),
        year: year,
        driverAge: age,
        cover: _cover,
      ),
    );
  }

  bool get _hasInput =>
      _makeCtrl.text.isNotEmpty ||
      _yearCtrl.text.isNotEmpty ||
      _licenceDate != null;

  Future<void> _reset() async {
    if (_hasInput) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('Your unsaved quote will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (confirmed != true) return;
    }
    _formKey.currentState!.reset();
    _makeCtrl.clear();
    _yearCtrl.clear();
    setState(() {
      _cover = Cover.comprehensive;
      _licenceDate = null;
      _autovalidate = AutovalidateMode.disabled;
    });
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    autovalidateMode: _autovalidate,
    child: _fields(context),
  );

  Widget _fields(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextFormField(
        controller: _makeCtrl,
        decoration: const InputDecoration(
          labelText: 'Vehicle make',
          hintText: 'e.g. VW',
        ),
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Make is required' : null,
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
      DropdownButtonFormField<Cover>(
        initialValue: _cover,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Cover'),
        items: [
          for (final c in Cover.values)
            DropdownMenuItem(
              value: c,
              child: Text(c.label, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (c) => setState(() => _cover = c ?? _cover),
      ),
      const SizedBox(height: 12),
      _LicenceDateField(
        value: _licenceDate,
        onChanged: (d) => setState(() => _licenceDate = d),
      ),
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
    final text = value == null
        ? 'Select date'
        : MaterialLocalizations.of(context).formatMediumDate(value!);
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
