// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'package:universal_io/io.dart'; // Import universal_io
import 'dart:async';
// import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb from foundation.dart
import 'cross_platform.dart';

void main() {
  runApp(MyApp()); // Pass the value of kIsWeb to the widget
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text File Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(), // Pass isWeb to MyHomePage
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String currentWord = '';
  double delay = 0.5;
  bool isReading = false;
  bool isPaused = false;
  double minDelay = 0.0;
  double maxDelay = 1.0;
  int currentWordIndex = 0;
  int totalWords = 0;
  List<String>? words = null;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> startReading() async {
    if (isReading || words == null) {
      return;
    }
    setState(() {
      isReading = true;
      isPaused = false;
    });

    // Read and process the text file from 'selectedFile'
    // Stream the words for reading
    for (int i = currentWordIndex; i < totalWords; i++) {
      if (!isReading || isPaused) {
        break;
      }

      // make it asynchronous
      await Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () {
        print('${currentWordIndex}/${totalWords}');
        if (!isPaused) {
          setState(() {
            currentWord = words![currentWordIndex];
            currentWordIndex++;
          });
        }
      });
    }

    setState(() {
      isPaused = true;
      isReading = false;
    });
  }

  void pauseReading() {
    setState(() {
      isPaused = !isPaused;
      print('Paused: $isPaused');
    });
  }

  void rewindWord() {
    if (currentWordIndex > 0) {
      currentWordIndex--;
      setState(() {
        currentWord = '';
      });
      print('Rewind Word: $currentWordIndex');
    }
  }

  void fastForwardWord() {
    if (currentWordIndex < totalWords - 1) {
      currentWordIndex++;
      setState(() {
        currentWord = '';
      });
      print('Fast Forward Word: $currentWordIndex');
    }
  }

  List<String> splitWords(String str)
  {
    return str.split(RegExp(r'[\s\t\n()\[\]\{\}''""]+'));
  }

  Future<void> loadTextFile() async {
    FileLoader.loadFile((content) {
      currentWordIndex = 0;
      words = splitWords(content);
      currentWord = words![currentWordIndex]; // Reset the current word
      totalWords = words!.length;
    });
  }

  double calculateProgress() {
    if (totalWords == 0) {
      return 0.0;
    }
    return (currentWordIndex / totalWords).toDouble();
  }

  void changeProgress(double value) {
    if (words == null) {
      return;
    }

    double newPosition = value * totalWords;
    if (newPosition < 0) {
      newPosition = 0;
    } else if (newPosition >= totalWords) {
      newPosition = totalWords - 1;
    }

    setState(() {
      currentWordIndex = newPosition.toInt();
      print(currentWordIndex);
      currentWord = words![currentWordIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text File Reader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 2,
              child : GestureDetector(
                onLongPress: () {
                  pauseReading();
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    // Dragged right (fast forward)
                    fastForwardWord();
                  } else {
                    // Dragged left (rewind)
                    rewindWord();
                  }
                },
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    currentWord,
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                // This function will be called when the user drags horizontally
                double newValue = details.localPosition.dx / context.size!.width;
                changeProgress(newValue); // Call your custom changeProgress function
              },
              onTapUp: (details) {
                // This function will be called when the user taps on the progress bar
                double newValue = details.localPosition.dx / context.size!.width;
                changeProgress(newValue); // Call your custom changeProgress function
              },
              child: LinearProgressIndicator(
                value: calculateProgress(),
                backgroundColor: Colors.grey,
                minHeight: 10.0,
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(isReading ? Icons.pause : Icons.play_arrow),
                  onPressed: isReading ? pauseReading : startReading,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Adjust the width as needed
                  child: Slider(
                    value: delay,
                    min: minDelay,
                    max: maxDelay,
                    onChanged: (value) {
                      setState(() {
                        delay = value;
                      });
                      print('Delay: $delay');
                    },
                  ),
                ),
                Text('${delay.toStringAsFixed(2)}s'),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: loadTextFile,
              child: Text('Load Text File'),
            ),
          ],
        ),
      ),
    );
  }
}