import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:siwatt_mobile/core/models/devices.dart'; // Import Device model
import 'package:siwatt_mobile/core/models/user_model.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';
import 'package:wifi_iot/wifi_iot.dart';

enum AddDeviceMode { add, reconfigure }

class AddDeviceController extends GetxController {
  final Dio _dio = Dio(); // For ESP connection

  // State variables
  var currentStep = 0.obs;
  var isLoading = false.obs;
  var isScanning = false.obs;
  var availableDevices = <WifiNetwork>[].obs;
  var selectedDeviceSSID = ''.obs;
  var deviceId = ''.obs;
  
  var mode = AddDeviceMode.add.obs;
  Device? existingDevice;

  // ESP8266 Access Point IP
  final String espBaseUrl = 'http://192.168.4.1';

  // Config Form
  final formKey = GlobalKey<FormState>();
  final wifiSsidController = TextEditingController();
  final wifiPassController = TextEditingController();
  final deviceNameController = TextEditingController();
  final deviceLocationController = TextEditingController();

  // Scanned networks from the ESP device perspective
  var targetNetworks = <String>[].obs;
  var isTargetScanning = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Check for arguments passed via Get.toNamed or Get.to
    if (Get.arguments != null && Get.arguments is Map) {
      if (Get.arguments['mode'] == AddDeviceMode.reconfigure) {
        mode.value = AddDeviceMode.reconfigure;
        existingDevice = Get.arguments['device'];
        if (existingDevice != null) {
          deviceNameController.text = existingDevice!.deviceName;
          deviceLocationController.text = existingDevice!.location;
        }
      }
    }
    
    // Start scanning immediately when entering the page
    scanForItems();
  }

  @override
  void onClose() {
    // Reset WiFi usage enforcement when leaving
    if (Platform.isAndroid) {
      WiFiForIoTPlugin.forceWifiUsage(false);
    }
    wifiSsidController.dispose();
    wifiPassController.dispose();
    deviceNameController.dispose();
    deviceLocationController.dispose();
    super.onClose();
  }

  Future<void> scanForItems() async {
    isScanning.value = true;
    availableDevices.clear();

    try {
      // Check permissions first
      if (await Permission.location.request().isGranted) {
        // Retrieve list of WiFi networks
        // Note: For Android 10+, this might require GPS to be on
        final List<WifiNetwork> list = await WiFiForIoTPlugin.loadWifiList();

        // Filter for SiWatt devices
        final siwattDevices = list.where((network) => (network.ssid != null && network.ssid!.startsWith('SiWatt'))).toList();

        // If reconfiguring, filter only devices matching the device code (assuming SSID contains it)
        List<WifiNetwork> filteredDevices = siwattDevices;
        if (mode.value == AddDeviceMode.reconfigure && existingDevice != null) {
           // We assume SSID format like "SiWatt-<DeviceCode>" or similar.
           // If we don't know exact format, we can try to match containment.
           filteredDevices = siwattDevices.where((network) => network.ssid!.contains(existingDevice!.deviceCode)).toList();
        }

        // Sort by Signal Strength (Level), descending
        filteredDevices.sort((a, b) => (b.level ?? -100).compareTo(a.level ?? -100));

        availableDevices.assignAll(filteredDevices);

        if (availableDevices.isEmpty) {
          // For testing purposes if no device is around, un-comment below
          /*
           availableDevices.add(WifiNetwork(
             ssid: "SiWatt-Test", 
             bssid: "00", 
             capabilities: "", 
             frequency: 2400, 
             level: -50, 
             timestamp: 0
           ));
           */
        }
      } else {
        Get.snackbar(
          "Permission Needed",
          "Location permission is required to scan for WiFi devices.",
          backgroundColor: SiwattColors.accentWarning,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to scan: $e", backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectToDevice(String ssid) async {
    isLoading.value = true;
    try {
      // On Android, we can force connection. On iOS, it will prompt.
      // We assume open network or a known password if "12345678" as per instructions
      bool connected = await WiFiForIoTPlugin.connect(
        ssid,
        password: "12345678", // Fixed password for SiWatt devices
        security: NetworkSecurity.WPA, // Adjust based on actual ESP security
        joinOnce: true,
        withInternet: false, // It's an IoT device, no internet
      );

      // If the plugin returns generic false but connects, it might differ by OS versions.
      // Let's assume user taps "Connect".

      // Attempt to verify connection by simple delay or checking current SSID
      await Future.delayed(const Duration(seconds: 3));
      String? currentSSID = await WiFiForIoTPlugin.getSSID();

      if (currentSSID == ssid || (currentSSID != null && currentSSID.contains(ssid))) {
        selectedDeviceSSID.value = ssid;

        // Force WiFi usage on Android to ensure traffic goes to the IoT device
        // even if mobile data is on.
        if (Platform.isAndroid) {
          await WiFiForIoTPlugin.forceWifiUsage(true);
        }

        // Fetch Device ID from the device
        await fetchDeviceDetails();

        currentStep.value = 1; // Move to next step

        // Once connected, fetch the scan list from the device itself
        fetchTargetNetworks();
      } else {
        // Try to proceed anyway if the user claims they are connected,
        // or show error.
        Get.snackbar(
          "Connection Failed",
          "Could not connect to $ssid. Please try manually in Settings if this fails.",
          backgroundColor: SiwattColors.accentDanger,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Connection error: $e", backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch WiFi networks stored/seen by the ESP device
  Future<void> fetchTargetNetworks() async {
    isTargetScanning.value = true;
    try {
      // Config timeouts for local AP connection
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);

      final response = await _dio.get('$espBaseUrl/scan');
      if (response.statusCode == 200 && response.data != null) {
        Map<String, dynamic> data = response.data;
        if (data.containsKey('networks')) {
          List<dynamic> nets = data['networks'];

          // Sort scanned networks by RSSI (Signal Strength)
          nets.sort((a, b) {
            int rssiA = a['rssi'] ?? -100;
            int rssiB = b['rssi'] ?? -100;
            return rssiB.compareTo(rssiA); // Descending
          });

          targetNetworks.assignAll(nets.map((e) => e['ssid'].toString()).toList());
        }
      }
    } catch (e) {
      print("Could not fetch networks from device: $e");
      // Maybe the device isn't ready or we aren't actually connected
    } finally {
      isTargetScanning.value = false;
    }
  }

  Future<void> fetchDeviceDetails() async {
    try {
      // Short timeout
      final response = await _dio.get('$espBaseUrl/status', options: Options(receiveTimeout: const Duration(seconds: 3)));
      if (response.statusCode == 200 && response.data != null) {
        // Parse device_id
        // Response example: {"device_id": "Ab3xYz", ... }
        if (response.data['device_id'] != null) {
          deviceId.value = response.data['device_id'].toString();
          print("Fetched Device ID: ${deviceId.value}");
        }
      }
    } catch (e) {
      print("Failed to fetch device status: $e");
    }
  }

  void selectTargetNetwork(String ssid) {
    wifiSsidController.text = ssid;
  }

  Future<void> submitConfiguration() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    // Get user from Hive
    var userBox = Hive.box('userBox');
    User? user = userBox.get('user');
    String username = user?.username ?? "unknown_user";

    // Default values as per requirement example
    final configData = {
      "wifi_ssid": wifiSsidController.text,
      "wifi_pass": wifiPassController.text,
      "username": username,
      "mqtt_server": "broker.emqx.io",
      "mqtt_port": 1883,
      "mqtt_user": "",
      "device_name": deviceNameController.text,
      "device_location": deviceLocationController.text,
      "report_interval": 1,
    };

    try {
      final response = await _dio.post(
        '$espBaseUrl/config',
        data: configData,
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200) {
        // Success
        Get.snackbar("Success", "Device Configured! It will restart now.", backgroundColor: SiwattColors.accentSuccess, colorText: Colors.white);

        // Disconnect from the IoT Device
        if (Platform.isAndroid) {
          await WiFiForIoTPlugin.forceWifiUsage(false);
        }
        await WiFiForIoTPlugin.disconnect();

        // If in Reconfigure mode, we stop here and go back.
        if (mode.value == AddDeviceMode.reconfigure) {
           Get.back(); // Close AddDevicePage
           Get.back(); // Close EditDevicePage or return to it
           Get.snackbar("Success", "Device Reconfigured Successfully", backgroundColor: SiwattColors.accentSuccess, colorText: Colors.white);
           return;
        }

        // Wait and Register to Backend
        Get.showSnackbar(const GetSnackBar(message: "Registering device to server...", showProgressIndicator: true, duration: Duration(seconds: 2)));

        // Wait a moment for network switchover (from local WiFi to Internet)
        await Future.delayed(const Duration(seconds: 4));

        await registerDeviceToBackend();

        // Refresh MainController to show new device
        if (Get.isRegistered<MainController>()) {
          final mainController = Get.find<MainController>();
          await mainController.refreshDevices();

          // Set the newly added device as current
          for (var device in mainController.devices) {
            print("Checking device: ${device.deviceCode} against ${deviceId.value}");
             if (device.deviceCode == deviceId.value) {
               mainController.changeDevice(device);
               break;
             }
          }
        }
        Get.offAllNamed('/main');
      } else {
        Get.snackbar("Error", "Device returned status: ${response.statusCode}", backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Process failed: $e", backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerDeviceToBackend() async {
    try {
      // Validate we have device code
      if (deviceId.value.isEmpty) {
        Get.snackbar(
          "Warning",
          "Device ID is missing. Cannot register to server.",
          backgroundColor: SiwattColors.accentWarning,
          colorText: Colors.white,
        );
        return;
      }else {
        Dio mainDio;
        if (!Get.isRegistered<DioClient>()) {
          // Retry fetching or init
          final dioClient = DioClient();
          await dioClient.init();
          Get.put(dioClient);
          mainDio = dioClient.dio;
        } else {
          mainDio = Get.find<DioClient>().dio;
        }

        final response = await mainDio.post(
          ApiUrl.devices,
          data: {"device_code": deviceId.value, "device_name": deviceNameController.text, "location": deviceLocationController.text},
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          Get.snackbar("Success", "Device Registered Successfully!", backgroundColor: SiwattColors.accentSuccess, colorText: Colors.white);
        } else {
          Get.snackbar(
            "Error",
            "Failed to register to server: ${response.statusCode}",
            backgroundColor: SiwattColors.accentDanger,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print("Backend registration error: $e");
      Get.snackbar(
        "Connection Error",
        "Could not register device to server. Please try again later.",
        backgroundColor: SiwattColors.accentDanger,
        colorText: Colors.white,
      );
    }
  }
}
