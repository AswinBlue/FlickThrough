import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'cross_platform.dart';
import 'package:permission_handler/permission_handler.dart';

AbstractFileLoader getFileLoader() => AppFileLoader();

class AppFileLoader implements AbstractFileLoader {
  @override
  Future<void> loadFile(Function callback) async {
    // check permission for read external storage
    var permission = await requestStoragePermission();

    if (permission != true) {
      print("Permission Denied");
      return;
    }
    // Code for mobile devices using file_picker package
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result != null && result.files.isNotEmpty) {
      // print('App file result : $result');
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

Future<bool> requestStoragePermission() async {
  final PermissionStatus status = await Permission.storage.request();

  if (status.isGranted) {
    // You have permission to access external storage.
    return true;
  } else {
    // Permission denied. Handle this case accordingly.
    return false;
  }
}


