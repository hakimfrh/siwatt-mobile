import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:siwatt_mobile/core/models/user_model.dart';
import 'package:siwatt_mobile/core/network/mqtt_config.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';
import 'package:siwatt_mobile/features/monitoring/models/monitoring_item.dart';

class MqttController extends GetxController {
  final MainController mainController = Get.find<MainController>();

  MqttServerClient? client;
  
  var isConnected = false.obs;
  var isConnecting = false.obs;
  var datapointLimit = 20.obs;
  var items = <MonitoringItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeItems();
    
    // Auto-reconnect on device switch
    ever(mainController.currentDevice, (device) {
      if (isConnected.value) {
        disconnect();
        connect();
      }
    });
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }

  Future<void> connect() async {
    if (isConnected.value) {
      disconnect();
      return;
    }
    
    if (isConnecting.value) return;

    final userBox = Hive.box('userBox');
    User? currentUser = userBox.get('user');
    final device = mainController.currentDevice.value;

    if (currentUser == null || device == null) return;

    isConnecting.value = true;

    // Unique Client ID
    String clientId = '${MqttConfig.clientIdentifier}_${DateTime.now().millisecondsSinceEpoch}';

    // Config: Prefer WSS (Secure WebSocket) on Port 8084 for best reachability
    String server = MqttConfig.server;
    int port = MqttConfig.port; 
    
    if (MqttConfig.useWebSockets) {
      server = 'wss://broker.emqx.io/mqtt'; 
      port = 8084; 
    }
    
    client = MqttServerClient.withPort(server, clientId, port);

    // Disable verbose logging for production
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;

    // Callbacks
    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;

    if (MqttConfig.useWebSockets) {
      client!.useWebSocket = true;
      client!.websocketProtocols = ['mqtt'];
    }
    
    client!.setProtocolV311();

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean();
    client!.connectionMessage = connMess;

    try {
      await client!.connect();
    } catch (e) {
      print('MQTT::Connection Exception: $e');
      client!.disconnect();
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      isConnecting.value = false;
      isConnected.value = true;
      
      // Reset previous values
      _initializeItems();
      
      String topic = '/${currentUser.username}/swm-raw/${device.deviceCode}';
      _subscribe(topic);
    } else {
      client!.disconnect();
      isConnecting.value = false;
    }
  }

  void _subscribe(String topic) {
    client!.subscribe(topic, MqttQos.atMostOnce);

    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMessage = c![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
      
      try {
        final data = jsonDecode(payload);
        _processData(data);
      } catch (e) {
        // Silent catch for parse errors
      }
    });
  }

  void disconnect() {
    client?.disconnect();
    isConnected.value = false;
    isConnecting.value = false;
  }

  void onConnected() {
    isConnected.value = true;
    isConnecting.value = false;
  }

  void onDisconnected() {
    isConnected.value = false;
    isConnecting.value = false;
  }

  // --- UI Monitoring Logic ---

  void _initializeItems() {
    items.value = [
      MonitoringItem(
        title: "Tegangan",
        value: "0.00",
        unit: "V",
        color: SiwattColors.chartVoltage,
        iconData: Icons.bolt,
        iconLetter: 'V',
        dataPoints: [],
        timestamps: [],
      ),
      MonitoringItem(
        title: "Arus",
        value: "0.00",
        unit: "A",
        color: SiwattColors.chartCurrent,
        iconData: Icons.electric_meter,
        iconLetter: 'A',
        dataPoints: [],
        timestamps: [],
      ),
      MonitoringItem(
        title: "Daya",
        value: "0.00",
        unit: "W",
        color: SiwattColors.chartPower,
        iconData: Icons.power,
        iconLetter: 'W',
        dataPoints: [],
        timestamps: [],
      ),
      MonitoringItem(
        title: "Faktor Daya",
        value: "0.00",
        unit: "",
        color: SiwattColors.chartEnergy,
        iconData: Icons.percent,
        iconLetter: 'Pf',
        dataPoints: [],
        timestamps: [],
      ),
      MonitoringItem(
        title: "Frekuensi",
        value: "0.00",
        unit: "Hz",
        color: SiwattColors.textSecondary,
        iconData: Icons.waves,
        iconLetter: 'Hz',
        dataPoints: [],
        timestamps: [],
      ),
    ];
  }

  void _processData(Map<String, dynamic> data) {
    DateTime timestamp = DateTime.now();
    if (data.containsKey('created_at')) {
      timestamp = DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now();
    } else if (data.containsKey('timestamp')) {
       // Handle numeric timestamp or string
       if (data['timestamp'] is int) {
         timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'] * 1000);
       } else {
         timestamp = DateTime.tryParse(data['timestamp'].toString()) ?? DateTime.now();
       }
    }

    _updateSingleItem(0, "voltage", data, timestamp);
    _updateSingleItem(1, "current", data, timestamp);
    _updateSingleItem(2, "power", data, timestamp);
    _updateSingleItem(3, "pf", data, timestamp);
    _updateSingleItem(4, "frequency", data, timestamp);
    items.refresh();
  }

  void _updateSingleItem(int index, String key, Map<String, dynamic> data, DateTime timestamp) {
    if (!data.containsKey(key)) return;
    if (index >= items.length) return;

    final rawVal = data[key];
    double doubleVal = 0.0;
    if (rawVal is num) {
      doubleVal = rawVal.toDouble();
    } else if (rawVal is String) {
      doubleVal = double.tryParse(rawVal) ?? 0.0;
    }

    var item = items[index];
    item.value = doubleVal.toStringAsFixed(2);
    item.dataPoints.add(doubleVal);
    item.timestamps.add(timestamp);
    
    while (item.dataPoints.length > datapointLimit.value) {
      item.dataPoints.removeAt(0);
      if (item.timestamps.isNotEmpty) item.timestamps.removeAt(0);
    }
  }

  void incrementLimit() {
    datapointLimit.value++;
    _trimLists();
  }

  void decrementLimit() {
    if (datapointLimit.value > 1) {
      datapointLimit.value--;
      _trimLists();
    }
  }

  void _trimLists() {
    for (var item in items) {
      while (item.dataPoints.length > datapointLimit.value) {
        item.dataPoints.removeAt(0);
        if (item.timestamps.isNotEmpty) item.timestamps.removeAt(0);
      }
    }
    items.refresh();
  }
}
