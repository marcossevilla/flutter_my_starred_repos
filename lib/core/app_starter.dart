import 'dart:async';

import 'package:emoji_lumberdash/emoji_lumberdash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumberdash/lumberdash.dart' as logger;

import '../presentation/app.dart';
import 'dependency_injection.dart';
import 'flavors.dart';

Future<void> startApp(Flavor flavor) async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      logger.putLumberdashToWork(
        withClients: [
          if (kDebugMode)
            EmojiLumberdash(
              errorMethodCount: 10,
              lineLength: 80,
            ),
        ],
      );

      FlutterError.onError = (details) {
        logger.logError(
          details.exception,
          stacktrace: details.stack,
        );
      };

      final injectionOverrides = await getInjectionOverrides(
        flavor: flavor,
      );

      runApp(
        ProviderScope(
          overrides: injectionOverrides,
          child: flavor == Flavor.prod
              ? const MyApp()
              : Directionality(
                  textDirection: TextDirection.ltr,
                  child: Banner(
                    message: flavor.tag,
                    location: BannerLocation.topStart,
                    child: const MyApp(),
                  ),
                ),
        ),
      );
    },
    (error, stackTrace) => logger.logError(
      error,
      stacktrace: stackTrace,
    ),
  );
}
