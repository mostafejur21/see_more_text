import 'package:flutter/material.dart';
import 'package:see_more_text/see_more_text.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SeeMoreText Test')),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SeeMoreText(
                text:
                    'This is a test of the new SeeMoreText widget with the text parameter instead of rawHtml. The default text color should be black, and it should handle URLs like https://flutter.dev, hashtags like #flutter, and mentions like @flutter_team.',
                maxLines: 2,
              ),
              SizedBox(height: 20),
              SeeMoreText(
                text: 'This is another test with custom styling.',
                maxLines: 1,
                textStyle: TextStyle(fontSize: 18, color: Colors.blue),
                linkStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
