import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// MidiFileConverter widget to convert MIDI files to a format of used in the app
/// not yet implemented
class MidiFileConverter extends StatefulWidget {
  const MidiFileConverter({super.key});

  @override
  MidiFileConverterState createState() => MidiFileConverterState();
}

class MidiFileConverterState extends State<MidiFileConverter> {
  String data = '';

  void onPressedBtn() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mid'],
        allowMultiple: false);
    if (result != null) {
      String path = result.files.single.path!;
      File file = File(path);
      List<int> selectedFile = await file.readAsBytes();
      log(selectedFile.toString());
      // TODO: Implement the conversion of the MIDI file to the format used in the app
      data = String.fromCharCodes(selectedFile);
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          decoration: const InputDecoration(
            labelText: 'Selected File',
          ),
          readOnly: true,
          controller: TextEditingController(text: data),
        ),
        ElevatedButton(
          onPressed: onPressedBtn,
          child: const Text('Open MIDI File'),
        ),
      ],
    );
  }
}
