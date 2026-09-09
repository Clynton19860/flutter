import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class CaptureForm extends StatefulWidget {
  const CaptureForm({
    super.key,
    required this.onSubmit,
  });

  final ValueChanged<QuoteRequest> onSubmit;

  @override
  State<CaptureForm> createState() => _CaptureFormState();
}

class _CaptureFormState extends State<CaptureForm> {
  final _formKey = GlobalKey<FormState>();

  final _makeController = TextEditingController();
  final _modelController = TextEditingController();

  int? _year;
  int? _driverAge;
  DateTime? _licenceDate;
  Cover _cover = Cover.comprehensive;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = QuoteRequest(
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: _year!,
      driverAge: _driverAge!,
      cover: _cover,
    );

    widget.onSubmit(request);
  }

  Future<void> _confirmReset() async {
    final hasData = _makeController.text.isNotEmpty ||
        _modelController.text.isNotEmpty ||
        _year != null ||
        _driverAge != null ||
        _licenceDate != null;

    if (!hasData) {
      _reset();
      return;
    }

    final confirmed =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Reset form?'),
                content: const Text(
                  'All entered values will be lost.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ) ??
        false;

    if (!context.mounted) return;

    if (confirmed) {
      _reset();
    }
  }

  void _reset() {
    _formKey.currentState!.reset();

    _makeController.clear();
    _modelController.clear();

    setState(() {
      _year = null;
      _driverAge = null;
      _licenceDate = null;
      _cover = Cover.comprehensive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Quote Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Make',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a vehicle make';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a vehicle model';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Vehicle Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  final year = int.tryParse(value ?? '');

                  if (year == null) {
                    return 'Please enter a year';
                  }

                  if (year < 1990 || year > DateTime.now().year) {
                    return 'Year must be between 1990 and ${DateTime.now().year}';
                  }

                  return null;
                },
                onChanged: (value) {
                  _year = int.tryParse(value);
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Driver Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  final age = int.tryParse(value ?? '');

                  if (age == null) {
                    return 'Please enter a driver age';
                  }

                  if (age < 18 || age > 100) {
                    return 'Age must be between 18 and 100';
                  }

                  return null;
                },
                onChanged: (value) {
                  _driverAge = int.tryParse(value);
                },
              ),

              const SizedBox(height: 16),

              _LicenceDateField(
                onChanged: (date) {
                  _licenceDate = date;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<Cover>(
                value: _cover,
                decoration: const InputDecoration(
                  labelText: 'Cover Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final cover in Cover.values)
                    DropdownMenuItem(
                      value: cover,
                      child: Text(cover.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _cover = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Get Quote'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _confirmReset,
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LicenceDateField extends StatefulWidget {
  const _LicenceDateField({
    required this.onChanged,
  });

  final ValueChanged<DateTime?> onChanged;

  @override
  State<_LicenceDateField> createState() => _LicenceDateFieldState();
}

class _LicenceDateFieldState extends State<_LicenceDateField> {
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365),
      ),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });

      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today),
      title: const Text('Licence Issue Date'),
      subtitle: Text(
        _selectedDate == null
            ? 'Tap to select'
            : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
      ),
      onTap: _pickDate,
    );
  }
}