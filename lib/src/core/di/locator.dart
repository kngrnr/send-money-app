import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'locator.config.dart';

final GetIt locator = GetIt.instance;

/// Setup dependency injection using injectable
/// All dependencies are configured with annotations
/// 
/// Call this before running the app:
/// ```dart
/// void main() {
///   configureDependencies();
///   runApp(MyApp());
/// }
/// ```
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => locator.init();

/// Reset the locator (useful for testing)
Future<void> resetLocator() async {
  await locator.reset();
}
