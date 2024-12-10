/*
MIT License

Copyright (c) 2020 J-P Nurmi <jpnurmi@gmail.com>
Copyright (c) 2024 Josef Sikula

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */
//
import 'package:flutter/material.dart';
import 'package:midi_xylophone/serial_port_selector.dart';

/// Main function of the app
void main() => runApp(const MIDIXylophoneApp());

/// Main app widget
class MIDIXylophoneApp extends StatefulWidget {
  const MIDIXylophoneApp({super.key});

  @override
  MIDIXylophoneAppState createState() => MIDIXylophoneAppState();
}

class MIDIXylophoneAppState extends State<MIDIXylophoneApp> {
  /// Key for accessing the MIDI source - SerialPortSelector
  final GlobalKey<SerialPortSelectorState> _serialPortMIDISourceKey =
      GlobalKey();



  /// Build widgets of the app
  /// sets the theme according to system (light/dark)
  /// and creates the app layout
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: Scaffold(
        
        body: Column(
          children: <Widget>[
            // Title
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(10),
              child: Text("MIDIx source",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ),
            // Serial port selector for MIDI source
            Container(
              alignment: Alignment.topLeft,
              child: SerialPortSelector(key: _serialPortMIDISourceKey),
            ),
            // Title
            Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.all(10),
              child: Text("Xylophone - MIDIx target",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ),
            // Serial port selector for MIDI target
            SerialPortSelector(
                keySerialPortMIDISource: _serialPortMIDISourceKey),
          ],
        ),
      ),
    );
  }
}
