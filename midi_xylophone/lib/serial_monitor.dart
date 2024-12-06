import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:midi_xylophone/control/serial_port_handler.dart';

class SerialMonitor extends StatefulWidget {
  final SerialPortHandler? serialPortHandler;

  const SerialMonitor({super.key, required this.serialPortHandler});

  @override
  SerialMonitorState createState() => SerialMonitorState();
}

class SerialMonitorState extends State<SerialMonitor> {
  String displayText = '';
  final ScrollController _scrollController = ScrollController();
  final int maxLines =
      6; // Maximum number of lines to display in the serial monitor

  void clearDisplayText() {
    setState(() {
      displayText = '';
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const Text('Serial Monitor'),
            Center(
              child: widget.serialPortHandler != null
                  ? StreamBuilder<String>(
                      stream: widget.serialPortHandler!.receivedData!,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Column(
                            children: [
                              CircularProgressIndicator(),
                              Text("Waiting for data...")
                            ],
                          ); // Display a loading indicator when waiting for data.
                        } else if (snapshot.hasError) {
                          log('Error: ${snapshot.error}');
                          return const Text(
                              "No serial monitor available"); // Display an error message if an error occurs.
                        } else if (snapshot.hasData) {
                          displayText +=
                              '${snapshot.data}'; // Append new data to displayText.
                          List<String> lines = displayText.split('\n');
                          if (lines.length > maxLines) {
                            lines = lines.sublist(lines.length - maxLines);
                          }
                          displayText = lines.join('\n');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          });
                          return TextField(
                            maxLines: 6,
                            controller:
                                TextEditingController(text: displayText),
                            readOnly: true,
                          ); // Display the accumulated data.
                        } else {
                          return const Text(
                              'No data available'); // Display a message when no data is available.
                        }
                      },
                    )
                  : const Text("No serial port handler found!"),
            )
          ],
        ),
      ),
    );
  }
}
