import 'package:logger/logger.dart';

mixin class LoggerMixin {
  Logger get logger => Logger(
    filter: DevelopmentFilter(),
    output: null,
    printer: HybridPrinter(
      SimplePrinter(colors: false, printTime: true),
      info: PrettyPrinter(colors: false, methodCount: 0),
      warning: PrettyPrinter(colors: false),
      error: PrettyPrinter(colors: false),
    ),
  );
}
