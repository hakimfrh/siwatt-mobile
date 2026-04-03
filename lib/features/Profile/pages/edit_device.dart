import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/models/devices.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';
import 'package:siwatt_mobile/features/add_device/pages/add_device.dart';
import 'package:siwatt_mobile/features/add_device/controllers/add_device_controller.dart';
import 'package:siwatt_mobile/features/profile/controllers/realtime_device_controller.dart';

class EditDevicePage extends StatefulWidget {
  final Device device;

  const EditDevicePage({super.key, required this.device});

  @override
  State<EditDevicePage> createState() => _EditDevicePageState();
}

class _EditDevicePageState extends State<EditDevicePage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  final TextEditingController _passwordController = TextEditingController();
  late final RealtimeDeviceController _realtimeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.deviceName);
    _locationController = TextEditingController(text: widget.device.location);

    // Initialize realtime controller for this specific device
    _realtimeController = Get.put(RealtimeDeviceController(widget.device.id), tag: 'edit_device_${widget.device.id}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    Get.delete<RealtimeDeviceController>(tag: 'edit_device_${widget.device.id}');
    super.dispose();
  }

  void _handleDelete() {
    _passwordController.clear();
    final isObscure = true.obs;
    final isLoading = false.obs;

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: SiwattColors.accentDanger, size: 24),
            SizedBox(width: 8),
            Text("Confirm Delete", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to remove this device? This action cannot be undone.",
              style: TextStyle(fontSize: 14, color: SiwattColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text(
              "Enter your password to confirm:",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SiwattColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Obx(
              () => TextField(
                controller: _passwordController,
                obscureText: isObscure.value,
                enabled: !isLoading.value,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: SiwattColors.textDisabled, fontSize: 14),
                  prefixIcon: const Icon(Icons.lock_outline, color: SiwattColors.textSecondary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscure.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: SiwattColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: isLoading.value ? null : () => isObscure.value = !isObscure.value,
                  ),
                  filled: true,
                  fillColor: SiwattColors.input,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: isLoading.value ? null : () => Get.back(),
              child: const Text("Cancel", style: TextStyle(color: SiwattColors.textSecondary)),
            ),
          ),
          Obx(
            () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SiwattColors.accentDanger,
                foregroundColor: Colors.white,
                minimumSize: const Size(90, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: isLoading.value
                  ? null
                  : () async {
                      if (_passwordController.text.isEmpty) {
                        Get.snackbar("Error", "Password cannot be empty", backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
                        return;
                      }
                      isLoading.value = true;
                      try {
                        final dio = Get.find<DioClient>().dio;
                        final response = await dio.delete('${ApiUrl.devices}/${widget.device.id}', data: {"password": _passwordController.text});

                        if (response.statusCode == 200) {
                          await Get.find<MainController>().refreshDevices();
                          Get.back(); // Close dialog
                          Get.back(); // Go back to profile
                          Get.snackbar("Success", "Device deleted", backgroundColor: SiwattColors.accentSuccess, colorText: Colors.white);
                        }
                      } catch (e) {
                        isLoading.value = false;
                        Get.back(); // Close dialog
                        Get.snackbar(
                          "Error",
                          "Failed to delete device. Check your password.",
                          backgroundColor: SiwattColors.accentDanger,
                          colorText: Colors.white,
                        );
                      }
                    },
              child: isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text("Remove", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() async {
    try {
      final dio = Get.find<DioClient>().dio;
      final response = await dio.put(
        '${ApiUrl.devices}/${widget.device.id}',
        data: {"device_name": _nameController.text, "location": _locationController.text},
      );

      if (response.statusCode == 200) {
        await Get.find<MainController>().refreshDevices();
        Get.back();
        Get.snackbar("Success", "Device updated successfully", backgroundColor: SiwattColors.accentSuccess, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update device", backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Edit Device",
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SiwattColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SiwattColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Status", style: textTheme.labelSmall?.copyWith(color: SiwattColors.textSecondary)),
                          const SizedBox(height: 4),
                          Obx(() {
                            final realtimeData = _realtimeController.realtimeData.value;
                            // Use realtime status if available, otherwise fallback to initial device status
                            final isOnline = realtimeData?.isOnline ?? widget.device.isActive;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOnline ? SiwattColors.accentSuccess.withOpacity(0.1) : SiwattColors.accentDanger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isOnline ? SiwattColors.accentSuccess : SiwattColors.accentDanger,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isOnline ? "Online" : "Offline",
                                    style: textTheme.bodySmall?.copyWith(
                                      color: isOnline ? SiwattColors.accentSuccess : SiwattColors.accentDanger,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Device Code", style: textTheme.labelSmall?.copyWith(color: SiwattColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(widget.device.deviceCode, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(context, "Added On", DateFormat("dd MMM yyyy").format(widget.device.createdAt)),
                      _buildInfoItem(
                        context,
                        "Last Online",
                        widget.device.lastOnline != null ? DateFormat("HH:mm, dd MMM").format(widget.device.lastOnline!) : "-",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildTextField(label: "Device Name", controller: _nameController, hint: "e.g. Living Room Meter", icon: Icons.edit_outlined),
            const SizedBox(height: 20),

            _buildTextField(label: "Location", controller: _locationController, hint: "e.g. Home - 1st Floor", icon: Icons.location_on_outlined),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiwattColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Get.to(() => const AddDevicePage(), arguments: {'mode': AddDeviceMode.reconfigure, 'device': widget.device});
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: SiwattColors.primary,
                  side: const BorderSide(color: SiwattColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_find_outlined, size: 20),
                    SizedBox(width: 8),
                    Text("Reconfigure Device", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _handleDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SiwattColors.accentDanger,
                  side: const BorderSide(color: SiwattColors.accentDanger),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text("Remove Device", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: SiwattColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required String hint, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SiwattColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: SiwattColors.input, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: SiwattColors.textDisabled, fontSize: 14),
              prefixIcon: Icon(icon, color: SiwattColors.textSecondary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
