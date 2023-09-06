import 'app.dart'
  if (dart.library.html) 'web.dart';

abstract class AbstractFileLoader {
  Future<void> loadFile(Function callback); // Use Function as the parameter type
  factory AbstractFileLoader.loadFile(Function callback) => throw UnimplementedError(); // Factory constructor should be defined properly
}

