import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/features/add_device/controllers/add_device_controller.dart';
import 'package:wifi_iot/wifi_iot.dart';

class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the controller
    final controller = Get.put(AddDeviceController());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () {
            // Ensure we clear the controller when going back
            Get.delete<AddDeviceController>();
            Get.back();
          },
        ),
        title: Obx(() => Text(
          controller.mode.value == AddDeviceMode.reconfigure ? 'Reconfigure Device' : 'Add New Device',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        )),
      ),
      body: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: controller.currentStep.value == 0
              ? _buildScanningStep(context, controller, colorScheme, textTheme)
              : _buildConfigStep(context, controller, colorScheme, textTheme),
        );
      }),
    );
  }

  Widget _buildScanningStep(
      BuildContext context,
      AddDeviceController controller,
      ColorScheme colorScheme,
      TextTheme textTheme) {
    return Container(
      key: const ValueKey('scanning'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sensors,
                size: 60,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Searching for SiWatt devices...",
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Make sure your device is plugged in and the indicator light is blinking.",
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Obx(() {
              
              if (controller.isScanning.value) {
                return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                );
              }

              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: controller.scanForItems,
                    child: controller.availableDevices.isEmpty
                    ? Stack(
                        children: [
                          ListView(), 
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wifi_off, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(controller.mode.value == AddDeviceMode.reconfigure 
                                    ? "Device '${controller.existingDevice?.deviceCode ?? ''}' not found" 
                                    : "No new devices found",
                                  style: textTheme.bodyLarge),
                                TextButton(
                                  onPressed: controller.scanForItems,
                                  child: const Text("Scan Again"),
                                )
                              ],
                            ),
                          ),
                        ],
                      ) 
                    : ListView.separated(
                      itemCount: controller.availableDevices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        WifiNetwork device = controller.availableDevices[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Icon(Icons.bolt, color: colorScheme.primary),
                            ),
                            title: Text(
                              device.ssid ?? "Unknown Device",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Signal Strength: ${device.level} dBm"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              if (device.ssid != null) {
                                controller.connectToDevice(device.ssid!);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  if (controller.isLoading.value)
                     Positioned.fill(
                       child: Container(
                         color: Colors.black.withOpacity(0.3),
                         child: Center(
                           child: Container(
                             padding: const EdgeInsets.all(24),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(16),
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.black.withOpacity(0.1),
                                   blurRadius: 10,
                                   spreadRadius: 2,
                                 )
                               ]
                             ),
                             child: Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 CircularProgressIndicator(color: colorScheme.primary),
                                 const SizedBox(height: 16),
                                 Text(
                                   "Connecting to Device...", 
                                   style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                                 ),
                               ],
                             ),
                           ),
                         ),
                       ),
                     ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigStep(
      BuildContext context,
      AddDeviceController controller,
      ColorScheme colorScheme,
      TextTheme textTheme) {
    return SingleChildScrollView(
      key: const ValueKey('config'),
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "Connected to ${controller.selectedDeviceSSID.value}",
              style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Setup Network & Info",
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            
            // WiFi Selection Section
            Text("Select WiFi Network", style: textTheme.labelLarge),
            const SizedBox(height: 10),
            Obx(() {
                 if (controller.isTargetScanning.value) {
                    return const LinearProgressIndicator();
                 }
                 if (controller.targetNetworks.isEmpty) {
                   return TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Refresh Networks"),
                      onPressed: controller.fetchTargetNetworks,
                   );
                 }
                 return SizedBox(
                   height: 50,
                   child: ListView.separated(
                     scrollDirection: Axis.horizontal,
                     itemCount: controller.targetNetworks.length,
                     separatorBuilder: (_, __) => const SizedBox(width: 8),
                     itemBuilder: (context, index) {
                         String net = controller.targetNetworks[index];
                         return ActionChip(
                           label: Text(net),
                           onPressed: () => controller.selectTargetNetwork(net),
                           backgroundColor: controller.wifiSsidController.text == net ? colorScheme.primaryContainer : null,
                         );
                     },
                   ),
                 );
            }),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: controller.wifiSsidController,
              label: "WiFi SSID",
              icon: Icons.wifi,
              colorScheme: colorScheme,
              validator: (v) => v?.isNotEmpty == true ? null : "Required",
            ),
            const SizedBox(height: 16),
             _buildTextField(
              controller: controller.wifiPassController,
              label: "WiFi Password",
              icon: Icons.lock_outline,
              isPassword: true,
              colorScheme: colorScheme,
               validator: (v) => v?.isNotEmpty == true ? null : "Required",
            ),
            
             if (controller.mode.value == AddDeviceMode.add) ...[
                const SizedBox(height: 30),
                Text("Device Details", style: textTheme.labelLarge),
                const SizedBox(height: 16),
                _buildTextField(
                 controller: controller.deviceNameController,
                 label: "Device Name (e.g. Living Room AC)",
                 icon: Icons.edit_outlined,
                 colorScheme: colorScheme,
                  validator: (v) => v?.isNotEmpty == true ? null : "Required",
               ),
               const SizedBox(height: 16),
                _buildTextField(
                 controller: controller.deviceLocationController,
                 label: "Location (e.g. Ground Floor)",
                 icon: Icons.place_outlined,
                 colorScheme: colorScheme,
                  validator: (v) => v?.isNotEmpty == true ? null : "Required",
               ),
             ],

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton(
                onPressed: () {
                    if(!controller.isLoading.value) {
                        controller.submitConfiguration();
                    }
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Obx(() => controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        controller.mode.value == AddDeviceMode.reconfigure ? "Reconfigure" : "Save & Activate",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      )),
              ),
            ),
             const SizedBox(height: 16),
             Center(
               child: TextButton(
                 onPressed: () {
                   controller.currentStep.value = 0;
                 }, 
                 child: const Text("Back to Scanning"),
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
