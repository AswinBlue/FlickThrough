import 'cross_platform.dart';
import 'dart:html' as html;  // Import the html package for web

class AppFileLoader implements FileLoader {
  @override
  Future<void> loadFile(Function callback) async {
    // Code for web
    final html.FileUploadInputElement input = html.FileUploadInputElement();

    input.click(); // Simulate a click on the file input element
    input.onChange.listen((e) {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsText(file, 'UTF-8');
      reader.onLoadEnd.listen((e) {
        if (reader.readyState == html.FileReader.DONE) {
          // split into string
          final content = reader.result as String;
          callback(content);
        }
      });
    });
  }
}
