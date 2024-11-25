import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

/// Read data from the serial port

void readData(SerialPort? serialPort) async {
  log('Reading data');
  Timer.periodic(const Duration(microseconds: 10), (timer) {
    log("Time: ${timer.tick}");
    while (true) {
    final data = serialPort!.read(2);
    if (data.isNotEmpty) {
      log('Data received: $data');
    }
  }
  });
  /*
  */
}

/// SerialPortSelector widget

class SerialPortSelector extends StatefulWidget {
  const SerialPortSelector({super.key, this.baudRate = 9600});
  final int baudRate;

  @override
  SerialPortSelectorState createState() => SerialPortSelectorState();
}

/// State class for the SerialPortSelector widget

class SerialPortSelectorState extends State<SerialPortSelector> {
  List<String> _availablePorts = [];
  String? _selectedPort;
  SerialPort? serialPort;
  bool _isPortOpen = false;
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

  void _openAndClosePort() {
    if (!_isPortOpen) {
      if (_selectedPort != null) {
        serialPort = SerialPort(_selectedPort!);
        final portconfig = SerialPortConfig();
        portconfig.baudRate = 115200;

        if (serialPort!.openReadWrite()) {
          serialPort!.config =
              portconfig; // Set the port configuration immedietly after opening the port
          _isPortOpen = true;
          log('Port opened successfully');
          startIsolate();
          log('Program is reading data on background');
          setState(() {
            openCloseBtnLabel = 'Close ${_selectedPort!} Port';
          });
        } else {
          log('Failed to open port');
        }
      }
    } else {
      _isolateSerialRead?.kill(priority: Isolate.immediate);
      serialPort!.close();
      _isPortOpen = false;
      log('Port closed');
      setState(() {
        openCloseBtnLabel = 'Open Port';
      });
    }
  }

  Future<void> startIsolate() async {
    _isolateSerialRead = await Isolate.spawn(readData, serialPort);
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
            onPressed: _openAndClosePort,
            child: Text(openCloseBtnLabel),
          ),
        ),
      ],
    );
  }
}
