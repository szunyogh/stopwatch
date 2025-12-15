import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final loggerProvider = Provider((ref) {
  return Logger(
    filter: DevelopmentFilter(),
    output: null,
    printer: HybridPrinter(
      SimplePrinter(colors: false, printTime: true),
      info: PrettyPrinter(colors: false, methodCount: 0),
      warning: PrettyPrinter(colors: false),
      error: PrettyPrinter(colors: false),
    ),
  );
});
