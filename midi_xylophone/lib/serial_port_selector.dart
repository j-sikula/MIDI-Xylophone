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
  bool isPortOpen =
      false; // disables dropdown when port is open, prevents changing port while port is open
  final GlobalKey<SerialMonitorState> _serialMonitorKey =
      GlobalKey<SerialMonitorState>(); // Key to access the SerialMonitor widget

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
    if (_selectedPort != null) {
      if (serialPortHandler == null ||
          serialPortHandler!.portName != _selectedPort) {
        // creates a new instance of SerialPortHandler class
        // if the serialPortHandler is not initialized or the port is changed
        serialPortHandler = SerialPortHandler(widget.baudRate, _selectedPort!);
      }
    } else {
      // if no port is selected
      return;
    }

    if (!serialPortHandler!.isPortOpen) {
      //to open the port
      if (serialPortHandler!.openPort()) {
        setState(() {
          openCloseBtnLabel = 'Close ${_selectedPort!} Port';
          isPortOpen = true;
        });
      }
    } else {
      //to close the port
      if (serialPortHandler!.closePort()) {
        setState(() {
          openCloseBtnLabel = 'Open Port';
          isPortOpen = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: DropdownMenu<String>(
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
            onPressed: openAndClosePort,
            child: Text(openCloseBtnLabel),
          ),
        ),
        SerialMonitor(
            key: _serialMonitorKey, serialPortHandler: serialPortHandler),
      ],
    );
  }
}
