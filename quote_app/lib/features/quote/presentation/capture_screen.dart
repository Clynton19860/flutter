import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';

class CaptureScreen extends StatelessWidget{
  final Cover _cover = Cover.comprehensive;
  double? _premium;

  CaptureScreen({super.key});

  void _calculate(){
    final request = QuoteRequest(make: 'VW', year: 2020, driverAge: 30, cover: _cover);
    _premium = calculatePremium(request);
  }
  QuoteRequest get request => QuoteRequest(make: 'VW', year: 2020, driverAge: 30, cover: _cover);
  
  Widget _brandHeader(BuildContext context, bool isLandscape) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      Positioned(
        left: 16, top: 16,
        child: Text('Alpha Insure',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
      ),
      Positioned(
        right: 16, top: isLandscape ? 170: null, bottom: isLandscape ? null : -20,
        child: Chip(label: const Text('Comprehensive'), backgroundColor: Colors.white),
      ),
      const Positioned.fill(
        child: Align(
          alignment: Alignment.center,
          child: Icon(Icons.shield, size: 48, color: Colors.white24),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) { 
    final Widget form = CaptureForm(onSubmit: (request) {
    _calculate();
  });
  
    return Scaffold(
    appBar: AppBar(title: const Text('Get a quote', style: TextStyle(color: Colors.white),), centerTitle: true, backgroundColor: Theme.of(context).colorScheme.primary),
    body: SafeArea(child: LayoutBuilder(builder: (context, constraints){
      final isScrollingColumn = constraints.maxWidth < 700;

      if(isScrollingColumn){
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(20), child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _brandHeader(context, false),
                  SizedBox(height: 24),
                  form,
                  const SizedBox(height: 24),
                  if (_premium != null) PremiumBadge(amount: _premium!),
                  ]))),
        );
      }
      return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20, right: 20),
                child: SizedBox(width: 400, child: _brandHeader(context, true)),
              ),
              Expanded(child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView( padding: const EdgeInsets.all(20), child: form),
              )),
              const SizedBox(height: 24),
              if (_premium != null) PremiumBadge(amount: _premium!),
            ],
          );
      
    }))
  );
  }

}

class PremiumBadge extends StatelessWidget{
  final double amount;

  const PremiumBadge({super.key, required this.amount});

  @override
  Widget build(BuildContext context) => Text(
    amount.rands,
    style: Theme.of(context).textTheme.headlineMedium
  );
}

extension Money on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}