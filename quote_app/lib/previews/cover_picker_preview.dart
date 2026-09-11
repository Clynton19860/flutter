import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:quote_app/core/theme/brand_theme.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/cover_picker.dart';

// Dev-only previews for CoverPicker. Not part of the shipped app - just an
// entry point for `flutter widget-preview start` / the IDE's preview panel.
// Kept out of features/ since it's tooling, not app code.

// theme:/wrapper: callback references must be public, static or top-level
// functions per the @Preview() contract - private (leading underscore)
// references are rejected.
const previewSize = Size.fromWidth(390);

Widget paddedPreviewWrapper(Widget child) =>
    Padding(padding: const EdgeInsets.all(16), child: child);

PreviewThemeData alphaPreviewTheme() => PreviewThemeData(
  materialLight: brands['alpha']!.toThemeData(Brightness.light),
  materialDark: brands['alpha']!.toThemeData(Brightness.dark),
);

PreviewThemeData betaPreviewTheme() => PreviewThemeData(
  materialLight: brands['beta']!.toThemeData(Brightness.light),
  materialDark: brands['beta']!.toThemeData(Brightness.dark),
);

@Preview(
  name: 'Cover picker - Alpha, comprehensive selected',
  size: previewSize,
  theme: alphaPreviewTheme,
  wrapper: paddedPreviewWrapper,
)
Widget previewCoverPickerAlphaComprehensive() =>
    CoverPicker(value: Cover.comprehensive, onChanged: (_) {});

@Preview(
  name: 'Cover picker - Alpha, third party selected',
  size: previewSize,
  theme: alphaPreviewTheme,
  wrapper: paddedPreviewWrapper,
)
Widget previewCoverPickerAlphaThirdParty() =>
    CoverPicker(value: Cover.thirdParty, onChanged: (_) {});

@Preview(
  name: 'Cover picker - Alpha, third party fire & theft selected',
  size: previewSize,
  theme: alphaPreviewTheme,
  wrapper: paddedPreviewWrapper,
)
Widget previewCoverPickerAlphaThirdPartyFireTheft() =>
    CoverPicker(value: Cover.thirdPartyFireTheft, onChanged: (_) {});

@Preview(
  name: 'Cover picker - Beta, comprehensive selected',
  size: previewSize,
  theme: betaPreviewTheme,
  wrapper: paddedPreviewWrapper,
)
Widget previewCoverPickerBetaComprehensive() =>
    CoverPicker(value: Cover.comprehensive, onChanged: (_) {});
