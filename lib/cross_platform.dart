// export 'app.dart' if (dart.library.html) 'web.dart';
import 'app.dart' if (dart.library.html) 'web.dart';
export 'web.dart' if (dart.library.io) 'app.dart';

abstract class AbstractFileLoader {
  Future<void> loadFile(Function callback) => throw UnimplementedError();// Use Function as the parameter type
  // const AbstractFileLoader();
  // AbstractFileLoader getFileLoader() => throw UnimplementedError();
  factory AbstractFileLoader() => getFileLoader();
}
