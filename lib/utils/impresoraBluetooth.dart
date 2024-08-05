import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:flutter/services.dart';
import 'package:restauflutter/utils/shared_pref.dart';

class StateBleotoothContent extends StatefulWidget {
  @override
  _StateBleotoothContentState createState() => _StateBleotoothContentState();
}

class _StateBleotoothContentState extends State<StateBleotoothContent> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  BluetoothDevice? _device;
  bool _connected = false;
  String tips = 'Pull down to refresh';
  SharedPref _conexionPref = SharedPref();
  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      print('******************* Current device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'Connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'Disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future<void> _refresh() async {
    await bluetoothPrint.startScan(timeout: Duration(seconds: 4));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: [],
                  builder: (context, snapshot) => Column(
                    children: snapshot.data!.map((device) => ListTile(
                      title: Text(device.name ?? ''),
                      subtitle: Text(device.address ?? ''),
                      onTap: () async {
                        setState(() {
                          _device = device;
                        });
                      },
                      trailing: _device != null && _device!.address == device.address
                          ? Icon(Icons.check, color: Colors.green)
                          : null,
                    )).toList(),
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            child: Text('Connect'),
                            onPressed: _connected
                                ? null
                                : () async {
                              if (_device != null && _device!.address != null) {
                                setState(() {
                                  tips = 'Connecting...';
                                });
                                await bluetoothPrint.connect(_device!);
                                setState(() {
                                  _connected = true;
                                  tips = 'Connected';
                                });
                              } else {
                                setState(() {
                                  tips = 'Please select a device';
                                });
                                print('Please select a device');
                              }
                              await _conexionPref.save('conexionBluetooth', _connected);
                            },
                          ),
                          SizedBox(width: 10.0),
                          OutlinedButton(
                            child: Text('Disconnect'),
                            onPressed: _connected
                                ? () async {
                              setState(() {
                                tips = 'Disconnecting...';
                              });
                              await bluetoothPrint.disconnect();
                              setState(() {
                                _connected = false;
                                tips = 'Disconnected';
                              });
                              await _conexionPref.save('conexionBluetooth', _connected);
                            }
                                : null,
                          ),
                        ],
                      ),
                      Divider(),
                      OutlinedButton(
                        child: Text('Print receipt (esc)'),
                        onPressed: _connected
                            ? () async {
                          Map<String, dynamic> config = Map();

                          List<LineText> list = [];

                          list.add(LineText(type: LineText.TYPE_TEXT, content: '**********************************************', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Receipt Header', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 2, linefeed: 1));
                          list.add(LineText(linefeed: 1));

                          list.add(LineText(type: LineText.TYPE_TEXT, content: '----------------------Details---------------------', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Item Name & Specifications', weight: 1, align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Unit', weight: 1, align: LineText.ALIGN_LEFT, x: 350, relativeX: 0, linefeed: 0));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Quantity', weight: 1, align: LineText.ALIGN_LEFT, x: 500, relativeX: 0, linefeed: 1));

                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Concrete C30', align: LineText.ALIGN_LEFT, x: 0, relativeX: 0, linefeed: 0));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: 'Ton', align: LineText.ALIGN_LEFT, x: 350, relativeX: 0, linefeed: 0));
                          list.add(LineText(type: LineText.TYPE_TEXT, content: '12.0', align: LineText.ALIGN_LEFT, x: 500, relativeX: 0, linefeed: 1));

                          list.add(LineText(type: LineText.TYPE_TEXT, content: '**********************************************', weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
                          list.add(LineText(linefeed: 1));

                          ByteData data = await rootBundle.load("assets/img/cart.png");
                          List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
                          String base64Image = base64Encode(imageBytes);
                          // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));
                          await bluetoothPrint.printReceipt(config, list);

                        }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 5,
          child: StreamBuilder<bool>(
            stream: bluetoothPrint.isScanning,
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return FloatingActionButton(
                  child: Icon(Icons.stop),
                  onPressed: () => bluetoothPrint.stopScan(),
                  backgroundColor: Colors.red,
                );
              } else {
                return FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () =>
                      bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
