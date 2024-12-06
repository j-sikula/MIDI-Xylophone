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

  /// Gets the available ports
  ///
  /// If the platform Android, uses the getAvailablePorts function from the serial_port_handler_android.dart file
  void _getAvailablePorts() async {
    List<String> availablePorts;
    if (Platform.isAndroid) {
      availablePorts = await getAvailablePorts();
    } else {
      availablePorts = SerialPort.availablePorts;
    }
    setState(() {
      _availablePorts = availablePorts;
    });
  }

  /// Callback function to open and close the selected port
  ///
  ///
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
        serialPortHandler!.writeData(data);
      });

      return true;
    } else {
      log('No SerialPortHandler of Xylophone');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context)
        .size; // Used for chaaing the width of the dropdown menu; Column or Row
    List<Widget> serialPortSelectorChildren = [
      Row(children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: DropdownMenu<String>(
            width: screenSize.width < 500
                ? screenSize.width * 0.7 // For smaller screens
                : null,
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
          margin: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              _getAvailablePorts(); // Refreshes the available ports
            },
            child: const Icon(Icons.refresh),
          ),
        ),
      ]),
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
      Platform.isAndroid
          ? Container(
              margin: const EdgeInsets.all(10),
              child: SerialMonitor(
                  key: _serialMonitorKey, serialPortHandler: serialPortHandler),
            )
          : Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: SerialMonitor(
                    key: _serialMonitorKey,
                    serialPortHandler: serialPortHandler),
              ),
            )
    ];
    if (screenSize.width < 500) {
      return Column(
        children: serialPortSelectorChildren,
      );
    } else {
      return Row(
        children: serialPortSelectorChildren,
      );
    }
  }
}
