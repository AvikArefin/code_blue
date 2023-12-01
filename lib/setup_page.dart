import 'dart:async';

import 'package:codeblue/number_page.dart';
import 'package:codeblue/location.dart';
import 'package:codeblue/sms.dart';
import 'package:direct_caller_sim_choice/direct_caller_sim_choice.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

import 'service_manager.dart';
import 'select_bonded_device_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  String _number1 = "";
  String _number2 = "";

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  PermissionStatus _smsPermissionStatus = PermissionStatus.denied;

  bool _autoAcceptPairingRequests = false;

  final DirectCaller directCaller = DirectCaller();

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {});

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CodeBlue'),
      ),
      body: ListView(
        children: <Widget>[
          const Divider(),
          const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text('General',
                  style: TextStyle(fontWeight: FontWeight.w200))),
          SwitchListTile(
            title: const Text('Enable Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              future() async {
                // async lambda seems to not working
                if (value) {
                  await FlutterBluetoothSerial.instance.requestEnable();
                } else {
                  await FlutterBluetoothSerial.instance.requestDisable();
                }
              }

              future().then((_) {
                setState(() {});
              });
            },
          ),
          ListTile(
            title: const Text('Bluetooth status'),
            subtitle: Text(_bluetoothState.toString()),
            trailing: ElevatedButton(
              child: const Text('Settings'),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
            ),
          ),
          const Divider(),
          const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text('Devices discovery and connection',
                  style: TextStyle(fontWeight: FontWeight.w200))),
          SwitchListTile(
            title: const Text('Auto-try specific pin when pairing'),
            subtitle: const Text('Pin 1234'),
            value: _autoAcceptPairingRequests,
            onChanged: (bool value) {
              setState(() {
                _autoAcceptPairingRequests = value;
              });
              if (value) {
                FlutterBluetoothSerial.instance.setPairingRequestHandler(
                    (BluetoothPairingRequest request) {
                  debugPrint("Trying to auto-pair with Pin 1234");
                  if (request.pairingVariant == PairingVariant.Pin) {
                    return Future.value("1234");
                  }
                  return Future.value(null);
                });
              } else {
                FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
              }
            },
          ),
          const Divider(),
          const Padding(
              padding: EdgeInsets.only(left: 16),
              child:
                  Text('SMS', style: TextStyle(fontWeight: FontWeight.w200))),
          SwitchListTile(
            title: const Text('Enable SMS'),
            value: _smsPermissionStatus.isGranted,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              future() async {
                // async lambda seems to not working
                if (value) {
                  await Permission.sms.request();
                  _smsPermissionStatus = await Permission.sms.status;
                }
              }

              future().then((_) {
                setState(() {});
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter emergency number 1',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  _number1 = value;
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter emergency number 2',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  _number2 = value;
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
                onPressed: () async {
                  Position position = await determinePosition();
                  List<Placemark> x = await placemarkFromCoordinates(
                      position.latitude, position.longitude);
                  String help = "Please Help!\n:Location:";
                  String locationToBeSent =
                      "${x[0].administrativeArea}${x[0].subLocality}${x[0].subThoroughfare}${x[0].thoroughfare}";
                  String str = help + locationToBeSent + position.toString();
                  debugPrint(str);
                  sms([_number1], str);
                  directCaller.makePhoneCall(_number1, simSlot: 1);
                },
                child: const Text('Test Now')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              child: const Text('Connect to paired device'),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                          checkAvailability: false);
                    },
                  ),
                );

                if (selectedDevice != null) {
                  debugPrint('Connect -> selected $selectedDevice.address');
                  _startChat(selectedDevice);
                } else {
                  debugPrint('Connect -> no device selected');
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return DataPage();
                      },
                    ),
                  );
                },
                child: const Text('Emergency No. List')),
          ),
        ],
      ),
    );
  }

  void _startChat(BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          List<String> numbers = [];
          if (_number1 != "") {
            numbers.add(_number1);
          }
          if (_number2 != "") {
            numbers.add(_number2);
          }
          print(numbers);
          return ServiceManager(server: server, recipients: numbers);
        },
      ),
    );
  }
}
