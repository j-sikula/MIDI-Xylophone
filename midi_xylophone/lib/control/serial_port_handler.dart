import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

/// Controls the serial port
/// parameters: [baudRate], [portName], [isCreatingSerialPort] - default true, on Android false, custom Serial port
/// 
class SerialPortHandler {
  // Baud rate of serial port
  final int baudRate;
  // Name of the port for example: COM1
  final String portName;
  // if true, creates a serial port object
  final bool isCreatingSerialPort;

  bool isPortOpen = false; // Flag to check if the port is open
  bool tryOpenPortOnceAgain =
      true; // after closing port, try to open it only once again
  SerialPort? serialPort;

  SerialPortReader? reader;
  late StreamController<String> receivedDataController;
  late StreamController<Uint8List> receivedBytesController;

  // stream with decoded data
  // purpose: displays received data in NoteDisplayer widget
  Stream<String>? receivedData;
  // stream with raw data 
  // purpose: sends raw data to MIDI target
  Stream<Uint8List>? receivedBytes;
  
  

  // Constructor
  SerialPortHandler(this.baudRate, this.portName, {this.isCreatingSerialPort = true}) {
    // Initialize the serial port
    if (isCreatingSerialPort) {
      serialPort = SerialPort(portName);
    }
    

    receivedDataController = StreamController<String>.broadcast();
    receivedBytesController = StreamController<Uint8List>.broadcast();

    receivedData = receivedDataController.stream;
    receivedBytes = receivedBytesController.stream;
  }

  /// Closes the serial port
  Future<bool> closePort() async{
    reader!.close();
    if (serialPort!.close()) {
      isPortOpen = false;

      log('Port closed successfully');
      return true;
    } else {
      log('Failed to close port');
      return false;
    }
  }

  /// Opens the serial port,
  /// configuration 8N1, 
  /// baud rate according to the baudRate parameter in the constructor
  /// returns true if port is opened successfully
  /// streams filled with received data

  Future<bool> openPort() async {
    final portConfig = SerialPortConfig();
    portConfig.baudRate = baudRate;
    portConfig.parity = SerialPortParity.none;
    portConfig.bits = 8;
    portConfig.stopBits = 1;
    if (serialPort!.openReadWrite()) {
      serialPort!.config =
          portConfig; // Set the port configuration immedietly after opening the port
      isPortOpen = true;
      log('Port opened successfully');
      reader = SerialPortReader(serialPort!);
      reader!.stream.listen((data) {
        receivedDataController.add(String.fromCharCodes(data));
        receivedBytesController.add(data);
      });

      return true;
    } else {
      closePort();
      if (tryOpenPortOnceAgain) {
        tryOpenPortOnceAgain = false;
        return openPort();
      }
      log('Failed to open port');
      return false;
    }
  }

  /// Writes data to the serial port
  void writeData(Uint8List data) {
    serialPort!.write(data);
  }
}
