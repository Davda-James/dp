import 'package:flutter/material.dart';
import 'profile.dart'; // Import your Profile screen
import 'notification.dart'; // Import your Notification screen
import 'home.dart';
import 'gps.dart';
import 'help_page.dart'; // Import your Home screen

class CustomDrawer extends StatelessWidget {
  final String? selectedItem;
  final Function(String) onItemSelected;

  const CustomDrawer({
    Key? key,
    required this.selectedItem,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF17203A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF17203A)),
              accountName: const Text('Priyanshu',
                  style: TextStyle(color: Colors.white)),
              accountEmail: null,
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/profile1.gif'),
                backgroundColor: Colors.white,
              ),
            ),
            _buildDrawerItem(
                Icons.edit_calendar_outlined, 'Ticket Booking', context),
            _buildDrawerItem(Icons.place, 'GPS', context),
            _buildDrawerItem(Icons.location_on, 'Verify Ticket', context),
            _buildDrawerItem(Icons.person, 'My Profile', context),
            _buildDrawerItem(Icons.notifications, 'Notifications', context),
            _buildDrawerItem(Icons.contact_mail, 'Help', context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context) {
    final isSelected = selectedItem == title;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (title == 'My Profile') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage()), // Navigate to the Profile screen
            );
          } else if (title == 'Notifications') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NotificationPage()), // Navigate to the Notification screen
            );
          } else if (title == 'Ticket Booking') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        title: 'Home',
                      )), // Navigate to the Home screen
            );
          } else if (title == 'GPS') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MapScreen()), // Navigate to the Notification screen
            );
          } else if (title == 'Help') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HelplinePage()), // Navigate to the Notification screen
            );
          } else {
            print('$title single tap');
          }
        },
        onDoubleTap: () {
          onItemSelected(title);
          print('$title double tapped!');
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: isSelected ? const Color(0xFF48CAEA) : Colors.transparent,
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected ? const Color(0xFF03045E) : Colors.white,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF03045E) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
