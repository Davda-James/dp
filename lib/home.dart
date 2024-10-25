import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'profile.dart'; // Ensure you import the LineIcons package
import 'sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _selectedFromLocation = 'From';
  String _selectedToLocation = 'To';
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  final List<String> _locations = ['North Campus', 'South Campus', 'Mandi'];

  // Animation controller for notification icon
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _timeSlots = ['Morning', 'Afternoon', 'Evening', 'Night'];

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
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  if (type == 'to' &&
                      _selectedFromLocation != 'From' &&
                      _locations[index] == _selectedFromLocation) {
                    return const SizedBox.shrink();
                  } // Skip this location
                  return ListTile(
                    title: Text(_locations[index]),
                    onTap: () {
                      setState(() {
                        if (type == 'from') {
                          _selectedFromLocation = _locations[index];
                          // Reset the To location to default when From location changes
                          _selectedToLocation = 'To'; // Reset to default
                        } else {
                          _selectedToLocation = _locations[index];
                        }
                      });
                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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
                        value: _selectedTimeSlot,
                        hint: const Text('Choose a time slot'),
                        items: _timeSlots.map((String slot) {
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
                      ),
                    ),
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
