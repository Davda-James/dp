import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.dart'; // Ensure you import the LineIcons package
import 'sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title});

  @override
  HomePageState createState() => HomePageState();
}

class AvailableBusesList extends StatelessWidget {
  final List<Map<String, dynamic>> availableBuses;
  final VoidCallback onClose;
  final ValueChanged<String> onBusSelected;

  AvailableBusesList({
    required this.availableBuses,
    required this.onClose,
    required this.onBusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Available Buses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: availableBuses.length,
                  itemBuilder: (context, index) {
                    String busInfo =
                        '${availableBuses[index]['busId']}'; // Example
                    return ListTile(
                      title: Text(busInfo),
                      onTap: () {
                        onBusSelected(busInfo);
                        Navigator.pop(context); // Close bottom sheet on tap
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: onClose,
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _selectedFromLocation = 'From';
  String _selectedToLocation = 'To';
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String? _selectedBusId;

  Map<int, String> routeMapping = {
    1: 'North Campus Mandi via South',
    2: 'North Campus Mandi (direct)',
    3: 'Mandi North Campus via South'
  };
  final List<String> _locations = ['North Campus', 'Mandi'];

  // Animation controller for notification icon
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _timeSlots = [
    '7:00 AM',
    '8:00 AM',
    '10:00 AM',
    '12:00 PM',
    '3:15 PM',
    '5:40 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateNotificationIcon() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  // Inside your HomePageState class

  List<String> _getFilteredLocations() {
    if (_selectedFromLocation == 'Mandi') {
      return ['North Campus via South']; // Only option when "From" is Mandi
    } else if (_selectedFromLocation == 'North Campus') {
      return [
        'Mandi via South',
        'Mandi (direct)'
      ]; // Options when "From" is North Campus
    }
    return _timeSlots;
  }

  Future<List<Map<String, dynamic>>> fetchAvailableBuses() async {
    final String route = '$_selectedFromLocation $_selectedToLocation';
    final String selectedSlot = _selectedTimeSlot ?? '';

    // Fetch buses from Firestore
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Buses')
          .where('time_route.$selectedSlot', isEqualTo: route)
          .get();

      // Convert QuerySnapshot to List of Maps
      final List<Map<String, dynamic>> documents = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      print(selectedSlot);
      return documents;
    } catch (e) {
      _showErrorDialog(e.toString());
    }
    return [];
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Occurred'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function to show available buses in a modal bottom sheet
  void _showAvailableBuses(List<Map<String, dynamic>> availableBuses) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return AvailableBusesList(
            availableBuses: availableBuses,
            onClose: () => Navigator.pop(context),
            onBusSelected: (String busId) {
              setState(() {
                _selectedBusId = busId;
              });
            });
      },
    );
  }

  void _handleBusTileTap() async {
    if (_selectedTimeSlot != null) {
      List<Map<String, dynamic>> availableBuses = await fetchAvailableBuses();
      _showAvailableBuses(availableBuses);
    } else {
      _showErrorDialog('Please fill all details before selecting a bus.');
    }
  }

  void _showLocationDrawer(String type) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select ${type == 'from' ? 'From' : 'To'} Location',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: (type == 'from')
                    ? _locations.length
                    : (_selectedFromLocation != 'From'
                        ? _getFilteredLocations().length
                        : 0),
                itemBuilder: (context, index) {
                  String locationToDisplay = (type == 'from')
                      ? _locations[index]
                      : _getFilteredLocations()[index];
                  // if (type == 'to' &&
                  //     _selectedFromLocation != 'From' &&
                  //     _locations[index] == _selectedFromLocation) {
                  //   return const SizedBox.shrink();
                  // } // Skip this location
                  return ListTile(
                    title: Text(locationToDisplay),
                    onTap: () {
                      setState(() {
                        if (type == 'from') {
                          _selectedFromLocation = locationToDisplay;
                          // Reset the To location to default when From location changes
                          _selectedToLocation = 'To'; // Reset to default
                          _selectedTimeSlot = null;
                        } else {
                          _selectedToLocation = locationToDisplay;
                          _selectedTimeSlot = null;
                        }
                      });
                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                    enabled: (type == 'to' && _selectedFromLocation == 'From')
                        ? false
                        : true,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _getAvailableTimings() {
    if (_selectedFromLocation == 'North Campus' &&
        _selectedToLocation == 'Mandi (direct)') {
      return ['5:40 PM']; // Only show this timing
    }

    // You can add more conditions here for other combinations
    return _timeSlots; // Default timings or other combinations
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      1.0 + _animation.value * 0.2, // Slight scaling on click
                  child: const Icon(Icons.notifications),
                );
              },
            ),
            onPressed: () {
              _animateNotificationIcon(); // Start the animation
            },
          ),
        ],
      ),
      drawer: SideBar(
        onItemSelected: (index) {
          setState(() {
            _selectedIndex =
                index; // Update selected index based on sidebar selection
          });
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.white, // Start color
            Colors.white, // End color
          ]),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white.withOpacity(0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // From Location Tile
                    ListTile(
                      leading:
                          const Icon(Icons.directions_bus, color: Colors.black),
                      title: Text(
                        _selectedFromLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () {
                        _showLocationDrawer('from');
                      },
                    ),
                    const Divider(),

                    // To Location Tile
                    ListTile(
                      leading:
                          const Icon(Icons.directions_bus, color: Colors.black),
                      title: Text(
                        _selectedToLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () {
                        _showLocationDrawer('to');
                      },
                    ),
                    const Divider(),

                    // Date of Journey Picker
                    ListTile(
                      leading:
                          const Icon(Icons.calendar_today, color: Colors.black),
                      title: const Text(
                        'Date of Journey',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        _selectedDate != null
                            ? DateFormat('EEE d-MMM').format(_selectedDate!)
                            : 'Select a date',
                      ),
                      onTap: () {
                        _selectDate(context);
                      },
                    ),
                    const Divider(),

                    // Bottom Buttons for Today/Tomorrow
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDate = DateTime.now();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                backgroundColor: Colors.grey.shade400,
                              ),
                              child: const Text(
                                'Today',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDate = DateTime.now()
                                      .add(const Duration(days: 1));
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                backgroundColor: Colors.grey.shade400,
                              ),
                              child: const Text(
                                'Tomorrow',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Time Slot Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value:
                            _getAvailableTimings().contains(_selectedTimeSlot)
                                ? _selectedTimeSlot
                                : null,
                        hint: const Text('Choose a time slot'),
                        items: _getAvailableTimings().map((String slot) {
                          return DropdownMenuItem<String>(
                            value: slot,
                            child: Text(slot),
                          );
                        }).toList(),
                        onChanged: (_selectedFromLocation != 'From' &&
                                _selectedToLocation != 'To' &&
                                _selectedDate != null)
                            ? (String? newValue) {
                                setState(() {
                                  _selectedTimeSlot = newValue;
                                });
                              }
                            : null,
                        isExpanded: true,
                        menuMaxHeight: 250,
                      ),
                    ),
                    const Divider(),
                    // Bus selected
                    ListTile(
                      leading:
                          const Icon(Icons.directions_bus, color: Colors.black),
                      title: Text(
                        _selectedBusId ?? 'Select Bus',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _handleBusTileTap,
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            rippleColor: Colors.black,
            haptic: true,
            tabBorderRadius: 30,
            tabActiveBorder: Border.all(color: Colors.grey, width: 1),
            tabBorder: Border.all(color: Colors.black, width: 1),
            tabShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8)
            ],
            curve: Curves.fastOutSlowIn,
            duration: const Duration(milliseconds: 250),
            gap: 8,
            activeColor: Colors.white,
            iconSize: 30,
            tabBackgroundColor: Colors.grey.shade500,
            padding: const EdgeInsets.all(16),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              GButton(
                icon: Icons.place,
                text: 'GPS',
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              GButton(
                icon: Icons.help,
                text: 'help',
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
