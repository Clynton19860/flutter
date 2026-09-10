import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';

class CaptureScreen extends ConsumerStatefulWidget{
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  void _showPremium(BuildContext context, QuoteRequest r) {
    final premium = calculatePremium(r);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Premium ${premium.rands}')),
    );
  }

  Widget _formCard(BuildContext context, Widget form) {
    return Card(
      elevation: 3,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(padding: EdgeInsets.all(20), child: form,),
    );
  }

  @override
  Widget build(BuildContext context) { 
    final Widget form = CaptureForm(onSubmit: (r) => _showPremium(context, r));
  
    return Scaffold(
    appBar: AppBar(
      title: Text(ref.watch(brandProvider).name),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          tooltip: 'Switch brand',
          onPressed: () => ref.read(brandKeyProvider.notifier).toggle(),
        ),
      ],
    ),
    body: SafeArea(child: LayoutBuilder(builder: (context, constraints){
      final isScrollingColumn = constraints.maxWidth < 700;
      const header = _BrandHeader();

      if(isScrollingColumn){
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(20), child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  header,
                  SizedBox(height: 24),
                  _formCard(context, form),
                  ]))),
        );
      }
      return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20, right: 20),
                child: SizedBox(width: 400, child: header),
              ),
              Expanded(child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView( padding: const EdgeInsets.all(20), child: _formCard(context, form)),
              )),
            ],
          );
      
    }))
  );
  }

}

class _BrandHeader extends ConsumerWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    final name = brand.name;
    final logoAsset = brand.logoAsset;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Positioned(
          left: 16, top: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(logoAsset, height: 28, semanticLabel: '$name logo'),
              const SizedBox(width: 8),
              Text(name, style: tt.titleLarge?.copyWith(color: cs.onPrimary)),
            ],
          ),
        ),
        Positioned(
          right: 16, top: null, bottom: -20,
          child: Chip(label: const Text('Comprehensive'), backgroundColor: cs.surface),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Icon(Icons.shield, size: 48, color: Colors.white24),
          ),
        ),
      ],
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