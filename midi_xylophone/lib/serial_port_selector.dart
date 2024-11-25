import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:midi_xylophone/control/serial_port_handler.dart';
import 'package:midi_xylophone/serial_monitor.dart';

/// SerialPortSelector widget

class SerialPortSelector extends StatefulWidget {
  const SerialPortSelector({super.key, this.baudRate = 115200});
  final int baudRate;

  @override
  SerialPortSelectorState createState() => SerialPortSelectorState();
}

/// State class for the SerialPortSelector widget

class SerialPortSelectorState extends State<SerialPortSelector> {
  List<String> _availablePorts = [];
  String? _selectedPort;
  SerialPortHandler? serialPortHandler;
  String openCloseBtnLabel = 'Open Port';
  Isolate? _isolateSerialRead;

  @override
  void initState() {
    super.initState();
    _getAvailablePorts();
  }

  void _getAvailablePorts() {
    setState(() {
      _availablePorts = SerialPort.availablePorts;
    });
  }

  /// Callback function to open and close the selected port
  void openAndClosePort() {
    if (_selectedPort != null && (serialPortHandler == null ||
        serialPortHandler!.portName != _selectedPort)) {
      //to create a new instance of SerialPortHandler
      serialPortHandler = SerialPortHandler(widget.baudRate, _selectedPort!);
    } else {
      return;
    }
    if (!serialPortHandler!.isPortOpen) {
      //to open the port
      if (serialPortHandler!.openPort()) {
        startIsolate();
        setState(() {
          openCloseBtnLabel = 'Close ${_selectedPort!} Port';
        });
      }
    } else {
      //to close the port
      _isolateSerialRead?.kill(priority: Isolate.immediate);
      if (serialPortHandler!.closePort()) {
        setState(() {
          openCloseBtnLabel = 'Open Port';
        });
      }
    }
  }

  /// Function to start independent thread
  /// reads data from the serial port
  Future<void> startIsolate() async {
    _isolateSerialRead = await Isolate.spawn(readData, serialPortHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: DropdownButton<String>(
            hint: const Text('Select Serial Port'),
            value: _selectedPort,
            onChanged: (String? newValue) {
              setState(() {
                _selectedPort = newValue;
              });
            },
            items: _availablePorts.map<DropdownMenuItem<String>>((String port) {
              return DropdownMenuItem<String>(
                value: port,
                child: Text(port),
              );
            }).toList(),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 10),
          child: ElevatedButton(
            onPressed: openAndClosePort,
            child: Text(openCloseBtnLabel),
          ),
        ),

        SerialMonitor(serialPortHandler: serialPortHandler)
      ],
    );
  }
}
