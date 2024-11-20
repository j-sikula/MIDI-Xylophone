import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialPortSelector extends StatefulWidget {
  @override
  _SerialPortSelectorState createState() => _SerialPortSelectorState();
}

class _SerialPortSelectorState extends State<SerialPortSelector> {
  List<String> _availablePorts = [];
  String? _selectedPort;
  SerialPort? _serialPort;

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

  void _openPort() {
    if (_selectedPort != null) {
      _serialPort = SerialPort(_selectedPort!);
      if (_serialPort!.openReadWrite()) {
        print('Port opened successfully');
      } else {
        print('Failed to open port');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton<String>(
          hint: Text('Select Serial Port'),
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
        ElevatedButton(
          onPressed: _openPort,
          child: Text('Open Port'),
        ),
      ],
    );
  }
}