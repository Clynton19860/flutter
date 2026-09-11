import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/cover_picker.dart';

// iOS-style field decoration: filled, borderless, rounded - kept local to
// this file rather than in BrandTheme, so it doesn't bleed into Settings,
// Saved or Onboarding.
InputDecoration _glassDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  String? errorText,
  Widget? suffixIcon,
}) {
  final cs = Theme.of(context).colorScheme;
  const radius = BorderRadius.all(Radius.circular(14));
  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorText: errorText,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: cs.surfaceContainerHigh.withValues(alpha: 0.6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: cs.error, width: 1.5),
    ),
  );
}

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

  Widget _fields(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CoverPicker(
          value: _cover,
          onChanged: (c) => setState(() => _cover = c),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _makeCtrl,
          decoration: _glassDecoration(
            context,
            label: 'Vehicle make',
            hint: 'e.g. VW',
          ),
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Make is required' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _yearCtrl,
          decoration: _glassDecoration(context, label: 'Year'),
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
        _LicenceDateField(
          value: _licenceDate,
          onChanged: (d) => setState(() => _licenceDate = d),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: widget.enabled ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            minimumSize: const Size.fromHeight(52),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          icon: widget.enabled
              ? const Icon(Icons.calculate)
              : const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
          label: Text(widget.enabled ? 'Get quote' : 'Calculating...'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _reset,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: const StadiumBorder(),
            side: BorderSide(color: cs.outlineVariant),
          ),
          child: const Text('Reset'),
        ),
      ],
    );
  }
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
        decoration: _glassDecoration(
          context,
          label: 'Licence issue date',
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
