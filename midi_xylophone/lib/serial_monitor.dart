import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (widget.serialPortHandler?.dataQueue != null && widget.serialPortHandler!.dataQueue.isNotEmpty) {
        setState(() {
          displayText +=
              "Data: ${String.fromCharCode(widget.serialPortHandler!.dataQueue.removeFirst())} \n";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Serial Monitor'),
            if (widget.serialPortHandler != null)
              Text('Baud Rate: ${widget.serialPortHandler!.baudRate}'),
            const Text('Data:'),
            Center(
              child: Text(displayText),
            )
          ],
        ),
      ),
    );
  }
}
