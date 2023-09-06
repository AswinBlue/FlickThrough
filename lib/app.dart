import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'cross_platform.dart';

class FileLoader implements AbstractFileLoader {
  @override
  Future<void> loadFile(Function callback) async {
    // Code for mobile devices using file_picker package
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result != null && result.files.isNotEmpty) {
      print('result : $result');
      try {
        File selectedFile = File(result.files.single.path!); // Get the selected file
        String fileContent = await selectedFile.readAsString(); // Read file as text
        callback(fileContent);
      } catch (e) {
        print('Error reading file: $e');
        return null; // Handle any errors
      }
    } // -> if result
  }
}
