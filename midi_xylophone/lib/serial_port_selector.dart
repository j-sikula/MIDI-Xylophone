import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:midi_xylophone/control/serial_port_handler.dart';
import 'package:midi_xylophone/control/serial_port_handler_android.dart';
import 'package:midi_xylophone/serial_monitor.dart';


/// SerialPortSelector widget

class SerialPortSelector extends StatefulWidget {
  const SerialPortSelector(
      {super.key, this.baudRate = 115200, this.keySerialPortMIDISource});
  final int baudRate;
  final GlobalKey<SerialPortSelectorState>? keySerialPortMIDISource;

  @override
  SerialPortSelectorState createState() => SerialPortSelectorState();
}

/// State class for the SerialPortSelector widget

class SerialPortSelectorState extends State<SerialPortSelector> {
  List<String> _availablePorts = [];
  String? _selectedPort;
  SerialPortHandler? serialPortHandler;
  String openCloseBtnLabel = 'Open Port';
  bool isPortOpen =
      false; // disables dropdown when port is open, prevents changing port while port is open
  final GlobalKey<SerialMonitorState> _serialMonitorKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _getAvailablePorts();
  }

  void _getAvailablePorts() async {
    _availablePorts = await getAvailablePorts();
    setState(() {
       if (Platform.isAndroid) {
        
       } else {
        _availablePorts = SerialPort.availablePorts;
       }
      
    });
  }

  /// Callback function to open and close the selected port
  void openAndClosePort() async {
    if (_selectedPort != null) {
      if (serialPortHandler == null ||
          serialPortHandler!.portName != _selectedPort) {
        // creates a new instance of SerialPortHandler class
        // if the serialPortHandler is not initialized or the port is changed
        if (Platform.isAndroid) {
          serialPortHandler =
              SerialPortHandlerAndroid(widget.baudRate, _selectedPort!);
        } else {
          serialPortHandler =
              SerialPortHandler(widget.baudRate, _selectedPort!);
        }
      }
    } else {
      // if no port is selected
      return;
    }

    if (!serialPortHandler!.isPortOpen) {
      //to open the port
      if (await serialPortHandler!.openPort()) {
        sendDataToXylophone(); // Sends data to the Xylophone if defined MIDI source
        setState(() {
          openCloseBtnLabel = 'Close ${_selectedPort!} Port';
          isPortOpen = true;
        });
      }
    } else {
      //to close the port
      if (await serialPortHandler!.closePort()) {
        setState(() {
          openCloseBtnLabel = 'Open Port';
          isPortOpen = false;
        });
      }
    }
  }

  /// Sends data to the Xylophone
  /// Listens to the received data from the keySerialPortMIDISource
  /// writes the data to the serial port
  /// Returns true if successful begin of data transfer
  bool sendDataToXylophone() {
    if (widget.keySerialPortMIDISource != null &&
        widget.keySerialPortMIDISource!.currentState!.serialPortHandler !=
            null) {
      widget.keySerialPortMIDISource!.currentState!.serialPortHandler!
          .receivedBytes!
          .listen((Uint8List data) {
        serialPortHandler!.serialPort!.write(data);
      });

      return true;
    } else {
      log('No SerialPortHandler of Xylophone');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: DropdownMenu<String>(
            enabled: !isPortOpen,
            initialSelection: _selectedPort,
            label: const Text('Select Port'),
            onSelected: (String? newValue) {
              setState(() {
                _selectedPort = newValue;
              });
            },
            dropdownMenuEntries:
                _availablePorts.map<DropdownMenuEntry<String>>((String port) {
              return DropdownMenuEntry<String>(
                value: port,
                label: port,
                enabled: !isPortOpen,
              );
            }).toList(),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 10),
          child: ElevatedButton(
            onPressed: () {
              _getAvailablePorts(); // Refreshes the available ports
              openAndClosePort();
            },
            child: Text(openCloseBtnLabel),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: SerialMonitor(
                key: _serialMonitorKey, serialPortHandler: serialPortHandler),
          ),
        ),
      ],
    );
  }
}
