import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter_libserialport/flutter_libserialport.dart';

/// Read data from the serial port

void readData(SerialPortHandler? serialPortHandler) async {
  log('Reading data');
  Timer.periodic(const Duration(microseconds: 10), (timer) {
     if (!serialPortHandler!.isPortOpen) {
        timer.cancel();
        return;
      }
      final data = serialPortHandler.serialPort!.read(1);
      if (data.isNotEmpty) {
        
        serialPortHandler.dataQueue.add(data[0]);
        log('Data: ${String.fromCharCodes(data)}');
      }
  });
  /*
  */
}

class SerialPortHandler {
  final int baudRate;
  final String portName;

  bool isPortOpen = false;  // Flag to check if the port is open
  SerialPort? serialPort;
  final Queue<int> dataQueue = Queue<int>(); // FIFO Buffer - Queue to store the data read from the serial port

  // Constructor
  SerialPortHandler(this.baudRate, this.portName) {
    // Initialize the serial port
    serialPort = SerialPort(portName);

  }
  /// Closes the serial port
  bool closePort() {
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

  bool openPort() {
    final portConfig = SerialPortConfig();
    portConfig.baudRate = baudRate;
    portConfig.parity = SerialPortParity.none;
    portConfig.bits = 8;
    portConfig.stopBits = 1;
    if (serialPort!.openReadWrite()) {
      serialPort!.config = portConfig; // Set the port configuration immedietly after opening the port
      isPortOpen = true;
      log('Port opened successfully');
      return true;
    } else {
      log('Failed to open port');
      return false;
    }
  }
}
