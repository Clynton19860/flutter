import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/app.dart';

void main(){
  return runApp(const ProviderScope(child: QuoteApp()));
}