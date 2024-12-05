import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialPortHandler {
  final int baudRate;
  final String portName;

  bool isPortOpen = false; // Flag to check if the port is open
  bool tryOpenPortOnceAgain =
      true; // after closing port, try to open it only once again
  SerialPort? serialPort;

  late SerialPortReader reader;
  late StreamController<String> receivedDataController;
  late StreamController<Uint8List> receivedBytesController;
  Stream<String>? receivedData;
  Stream<Uint8List>? receivedBytes;

  // Constructor
  SerialPortHandler(this.baudRate, this.portName) {
    // Initialize the serial port
    serialPort = SerialPort(portName);

    receivedDataController = StreamController<String>.broadcast();
    receivedBytesController = StreamController<Uint8List>.broadcast();

    receivedData = receivedDataController.stream;
    receivedBytes = receivedBytesController.stream;
  }

  /// Closes the serial port
  Future<bool> closePort() async{
    reader.close();
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
  /// configuration 8N1
  ///  baud rate according to the baudRate parameter in the constructor

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
      reader.stream.listen((data) {
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
}
