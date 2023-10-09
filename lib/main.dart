// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:flutter/material.dart';
import 'dart:async';
import 'cross_platform.dart';
import 'custom_dialog.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';


void main() {
  AbstractFileLoader fileLoader = getFileLoader(); // file loading interface
  runApp(MyApp(fileLoader: fileLoader)); // Pass the value of kIsWeb to the widget
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.fileLoader});
  AbstractFileLoader fileLoader;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text File Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate, // custom delegate
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // template-arb-file 로 대체되는것 같아 제거함
      // localeListResolutionCallback: (locales, supportedLocales) {
      //   print('device locales=$locales supported locales=$supportedLocales');
      //   for (Locale locale in locales!) {
      //     // if device language is supported by the app,
      //     // just return it to set it as current app language
      //     if (supportedLocales.contains(locale)) {
      //       return locale;
      //     }
      //   }
      //   // if language of current location is not supported, use english
      //   return Locale('en');
      // },

      home: MyHomePage(fileLoader:fileLoader),

    );
  }
}

class MyHomePage extends StatefulWidget {
  // MyHomePage({Key? fileLoader}) : super(key: fileLoader);
  MyHomePage({required this.fileLoader});
  AbstractFileLoader fileLoader;

  @override
  _MyHomePageState createState() => _MyHomePageState(fileLoader:fileLoader);
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
  // AbstractFileLoader get fileLoader => widget.fileLoader;
  AbstractFileLoader fileLoader;
  List<String>? words = null;

  _MyHomePageState({required this.fileLoader});

  // @override
  // void initState() {
  //   super.initState();
  //   // You can now access 'fileLoader' directly in this state class
  //   fileLoader.loadFile((content) {
  //     // Your code here
  //   });
  // }

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

    // if cursor is already in the end, start from beginning
    if (currentWordIndex == totalWords)
    {
      currentWordIndex = 0;
    }

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
    try{
      this.fileLoader.loadFile((content) {
        currentWordIndex = 0;
        words = splitWords(content);
        currentWord = words![currentWordIndex]; // Reset the current word
        totalWords = words!.length;
      });
    } catch(e) {
      print("Error: $e");
    }
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
        title: Text(AppLocalizations.of(context).textFileReader),
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
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return CustomDialog();
                  },
                );
                if (result != null) {
                  currentWordIndex = 0;
                  words = splitWords(result);
                  currentWord = words![currentWordIndex]; // Reset the current word
                  totalWords = words!.length;
                  print('Entered Text: $result');
                }
              },
              child: Text(AppLocalizations.of(context).pasteFromClipBoard),
            ),
          ],
        ),
      ),
    );
  }
}
