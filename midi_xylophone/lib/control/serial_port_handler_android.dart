import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:midi_xylophone/control/serial_port_handler.dart';
import 'package:usb_serial/usb_serial.dart';

Future<List<String>> getAvailablePorts() async{
  List<String> ports = [];

  List<UsbDevice> devices = await UsbSerial.listDevices();
  log("Get available ports");
	log(devices.toString());
  UsbSerial.listDevices().then((devices) {
    for (var device in devices) {
      ports.add(device.deviceName);
    }
  });
  return ports;
}

class SerialPortHandlerAndroid extends SerialPortHandler {
  SerialPortHandlerAndroid(super.baudRate, super.portName);

  UsbPort? usbPort;
  late StreamSubscription<Uint8List> _subscription;

  @override
  Future<bool> closePort() async {
    await _subscription.cancel();
    bool closeResult = await usbPort!.close();
    if (closeResult) {
      isPortOpen = false;
      log('Port closed successfully');
      return true;
    } else {
      log('Failed to close port');
      return false;
    }
  }

  /// Opens the serial port
  @override
  Future<bool> openPort() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();

    for (var device in devices) {
      if (device.deviceName == portName) {
        usbPort = await device.create();
        break;
      }
    }

    if (usbPort == null) {
      log('Device not found');
      return false;
    }

    bool openResult = await usbPort!.open();
    if (!openResult) {
      log('Failed to open port');
      return false;
    }

    await usbPort!.setDTR(true);
    await usbPort!.setRTS(true);
    await usbPort!.setPortParameters(
        baudRate, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    isPortOpen = true;
    _subscription = usbPort!.inputStream!.listen((Uint8List data) {
      super.receivedBytesController.add(data);
      super.receivedDataController.add(String.fromCharCodes(data));
    });

    log('Port opened successfully');
    return true;
  }
}
