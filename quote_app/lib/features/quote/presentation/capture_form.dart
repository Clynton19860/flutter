import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

class CaptureForm extends StatefulWidget {
  const CaptureForm({super.key, required this.onSubmit, this.enabled = true});
  final void Function(QuoteRequest) onSubmit;
  final bool enabled;

  @override
  State<CaptureForm> createState() => _CaptureFormState();
}

class _CaptureFormState extends State<CaptureForm> {
  final _formKey = GlobalKey<FormState>();
  final _makeCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  Cover _cover = Cover.comprehensive;
  DateTime? _licenceDate;

  @override
  void dispose() {
    _makeCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final year = int.parse(_yearCtrl.text);
    // TODO: debug ref(clockProvider)
    final licenceYear = _licenceDate?.year ?? ref.read(clockProvider)().year;
    final age = ref.read(clockProvider)().year - licenceYear + 18;
    widget.onSubmit(QuoteRequest(
      make: _makeCtrl.text.trim(),
      year: year,
      driverAge: age,
      cover: _cover,
    ));
  }

  void _reset() {
    _formKey.currentState!.reset();
    _makeCtrl.clear();
    _yearCtrl.clear();
    setState(() {
      _cover = Cover.comprehensive;
      _licenceDate = null;
    });
  }

  @override
  Widget build(BuildContext context) =>
      Form(key: _formKey, child: _fields(context));

  Widget _fields(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _makeCtrl,
            decoration: const InputDecoration(
                labelText: 'Vehicle make', hintText: 'e.g. VW'),
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
              // TODO: debug ref(clockProvider)
              if (y < 1990 || y > ref.read(clockProvider)().year) {
                return 'Year must be 1990-${ref.read(clockProvider)().year}';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Cover>(
            initialValue: _cover,
            decoration: const InputDecoration(labelText: 'Cover'),
            items: [
              for (final c in Cover.values)
                DropdownMenuItem(value: c, child: Text(c.label)),
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
            onPressed: widget.enabled ? _submit : null, // null = disabled
            icon: widget.enabled
                ? const Icon(Icons.calculate)
                : const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
            label: Text(widget.enabled ? 'Get quote' : 'Calculating...'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: widget.enabled ? _reset : null,
            child: const Text('Reset'),
          ),
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
        // TODO: debug ref(clockProvider)
        child: InkWell(
          onTap: () async {
            final now = ref.read(clockProvider)();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime(ref.read(clockProvider)().year - 5),
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
