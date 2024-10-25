import 'package:flutter/material.dart';
import 'profile.dart';

class SideBar extends StatelessWidget {
  final Function(int) onItemSelected;

  const SideBar({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  // backgroundImage: AssetImage('assets/profile_picture.png'), // Add your own image
                ),
                SizedBox(height: 8),
                Text(
                  'User Name',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('ticket booking'),
            onTap: () {
              onItemSelected(0);
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('GPS'),
            onTap: () {
              onItemSelected(1);
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              onItemSelected(2);
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              onItemSelected(3);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout action here
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
