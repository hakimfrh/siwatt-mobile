import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/models/devices.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/core/network/api_url.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';

class EditDevicePage extends StatefulWidget {
  final Device device;

  const EditDevicePage({super.key, required this.device});

  @override
  State<EditDevicePage> createState() => _EditDevicePageState();
}

class _EditDevicePageState extends State<EditDevicePage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.deviceName);
    _locationController = TextEditingController(text: widget.device.location);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleDelete() {
    Get.defaultDialog(
      title: "Confirm Delete",
      middleText: "Are you sure you want to remove this device? This action cannot be undone.",
      textConfirm: "Remove",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: SiwattColors.accentDanger,
      onConfirm: () async {
        try {
          final dio = Get.find<DioClient>().dio;
          final response = await dio.delete('${ApiUrl.devices}/${widget.device.id}');

          if (response.statusCode == 200) {
            await Get.find<MainController>().refreshDevices();
            Get.back(); // Close dialog
            Get.back(); // Go back to profile
            Get.snackbar("Success", "Device deleted", backgroundColor: SiwattColors.accentSuccess, colorText: Colors.white);
          }
        } catch (e) {
          Get.back(); // Close dialog
          Get.snackbar("Error", "Failed to delete device", backgroundColor: SiwattColors.accentDanger, colorText: Colors.white);
        }
      }
    );
  }

  void _handleSave() async {
     try {
       final dio = Get.find<DioClient>().dio;
       final response = await dio.put(
         '${ApiUrl.devices}/${widget.device.id}',
         data: {
           "device_name": _nameController.text,
           "location": _locationController.text,
         }
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
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.device.isActive ? SiwattColors.accentSuccess.withOpacity(0.1) : SiwattColors.accentDanger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: widget.device.isActive ? SiwattColors.accentSuccess : SiwattColors.accentDanger,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.device.isActive ? "Online" : "Offline",
                                  style: textTheme.bodySmall?.copyWith(
                                    color: widget.device.isActive ? SiwattColors.accentSuccess : SiwattColors.accentDanger,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Device Code", style: textTheme.labelSmall?.copyWith(color: SiwattColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            widget.device.deviceCode,
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        context, 
                        "Added On", 
                        DateFormat("dd MMM yyyy").format(widget.device.createdAt)
                      ),
                      _buildInfoItem(
                        context, 
                        "Last Online", 
                        widget.device.lastOnline != null 
                            ? DateFormat("HH:mm, dd MMM").format(widget.device.lastOnline!)
                            : "-"
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            _buildTextField(
              label: "Device Name",
              controller: _nameController,
              hint: "e.g. Living Room Meter",
              icon: Icons.edit_outlined,
            ),
            const SizedBox(height: 20),
            
            _buildTextField(
              label: "Location",
              controller: _locationController,
              hint: "e.g. Home - 1st Floor",
              icon: Icons.location_on_outlined,
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiwattColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Save Changes", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                 child: const Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.delete_outline, size: 20),
                     SizedBox(width: 8),
                     Text(
                      "Remove Device", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
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
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: SiwattColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: SiwattColors.input,
            borderRadius: BorderRadius.circular(12),
          ),
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
