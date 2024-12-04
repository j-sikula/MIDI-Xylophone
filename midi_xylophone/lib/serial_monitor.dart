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
  final int maxLines = 30;  // Maximum number of lines to display in the serial monitor

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
            if (widget.serialPortHandler != null)
              Text('Baud Rate: ${widget.serialPortHandler!.baudRate}'),
            const Text('Data:'),
            Center(
              child: widget.serialPortHandler != null
              ? StreamBuilder<String>(
                  stream: widget.serialPortHandler!.receivedData!,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Display a loading indicator when waiting for data.
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Display an error message if an error occurs.
                    } else if (snapshot.hasData) {
                      displayText += '${snapshot.data}'; // Append new data to displayText.
                      List<String> lines = displayText.split('\n');
                      if (lines.length >maxLines) {
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
                      return Text(
                        displayText,
                        style: const TextStyle(fontSize: 14),
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
