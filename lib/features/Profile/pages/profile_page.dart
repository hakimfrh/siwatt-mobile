import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/models/devices.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';
import 'package:siwatt_mobile/features/profile/widgets/device_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final MainController mainController = Get.find<MainController>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
             Stack(
               alignment: Alignment.center,
               clipBehavior: Clip.none,
               children: [
                 // Green Background Curve
                 ClipPath(
                   clipper: _HeaderClipper(),
                   child: Container(
                     height: 180,
                     color: SiwattColors.primary,
                   ),
                 ),
                 
                 // Profile Image
                 const Positioned(
                   bottom: -50,
                   child: CircleAvatar(
                     radius: 60,
                     backgroundColor: Colors.white,
                     child: CircleAvatar(
                       radius: 55,
                       backgroundColor: Colors.grey,
                      //  backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Budi+Sulaiman&size=128'), 
                       // Or Icon as requested
                       child: Icon(Icons.person, size: 60, color: Colors.white),
                     ),
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 60),
             
             // User Info
             Text(
               mainController.user?.fullName ?? "-",
               style: textTheme.headlineLarge?.copyWith(
                 fontWeight: FontWeight.bold,
               ),
             ),
             Text(
               mainController.user?.email ?? "-",
                style: textTheme.bodyMedium
             ),
             const SizedBox(height: 12),
             
             // Edit Profile Button
             ElevatedButton(
               onPressed: () {},
               style: ElevatedButton.styleFrom(
                 backgroundColor: SiwattColors.primary,
                 foregroundColor: Colors.white,
                 minimumSize: const Size(0, 40),
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(8),
                 ),
                 textStyle: textTheme.labelLarge?.copyWith(
                   fontWeight: FontWeight.w500,
                 ),
               ),
               child: const Text("Edit Profile"),
             ),
             
             const SizedBox(height: 16),
             
             // Devices Section
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     "Daftar Smart Meter",
                     style: textTheme.bodyLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.w600),
                   ),
                   const SizedBox(height: 8),
                   
                   // Tambah Button
                   InkWell(
                     onTap: () {},
                     child: Container(
                       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                       decoration: BoxDecoration(
                         color: SiwattColors.primaryDark,
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                             "Tambah",
                             style: textTheme.bodyMedium?.copyWith(
                               color: Colors.white,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                           Icon(Icons.add, color: Colors.white),
                         ],
                       ),
                     ),
                   ),
                   
                   const SizedBox(height: 16),
                   const Divider(),
                   
                   // Active Device List
                   Obx(() {
                     if (mainController.devices.isEmpty) {
                       return const Center(child: Padding(
                         padding: EdgeInsets.all(16.0),
                         child: Text("Belum ada smart meter"),
                       ));
                     }
                     return ListView.separated(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       itemCount: mainController.devices.length,
                       separatorBuilder: (context, index) => const Divider(height: 32),
                       itemBuilder: (context, index) {
                         final device = mainController.devices[index];
                         return DeviceCard(device: device);
                       },
                     );
                   }),
                   const SizedBox(height: 40),
                 ],
               ),
             ),
          ],
        ),  
      ),
    );
  }
}


class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height + 50, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
