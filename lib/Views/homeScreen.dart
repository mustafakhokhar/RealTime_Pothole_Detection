import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pothole_detection_realtime/Widgets/HomeScreenElements.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Declaration
    List<Map> menuItems = [
      {
        'title': 'Profile',
        'icon': Icons.person_outline_outlined,
        'iconColor': Colors.indigo,
        'onPressed': () {
          print('Profile');
        }
      },
      {
        'title': 'Your Contributions',
        'icon': Icons.confirmation_num_outlined,
        'iconColor': Colors.indigo,
        'onPressed': () {
          print('Your Contributions');
        }
      },
      {
        'title': 'About Us',
        'icon': Icons.info_outline,
        'iconColor': Colors.indigo,
        'onPressed': () {
          print('About Us');
        }
      },
      {
        'title': 'Contact Us',
        'icon': Icons.email_outlined,
        'iconColor': Colors.indigo,
        'onPressed': () {
          print('Contact Us');
        }
      },
      {
        'title': 'Logout',
        'icon': Icons.power_settings_new_outlined,
        'iconColor': Colors.red,
        'onPressed': () {
          print('Logout');
        }
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
      backgroundColor: Colors.white,
      endDrawer: Drawer(
        width: Get.width * 0.7,
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Spot The Pothole',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListView.builder(
              itemCount: menuItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 1,
                  child: ListTile(
                    leading: Icon(
                      menuItems[index]['icon'],
                      color: menuItems[index]['iconColor'],
                    ),
                    title: Text(
                      menuItems[index]['title'],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      menuItems[index]['onPressed']();
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: HomeScreenElements(),
      ),
    );
  }
}
