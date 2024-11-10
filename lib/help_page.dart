import 'package:flutter/material.dart';

class HelplinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF17203A),
        scaffoldBackgroundColor: Color(0xFFF0F4FA),
        iconTheme: IconThemeData(color: Color(0xFF17203A)),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF4A5670)),
          bodyMedium: TextStyle(color: Color(0xFF4A5670)),
        ),
      ),
      home: Scaffold(
        body: HelplineScreen(),
      ),
    );
  }
}

class HelplineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Helpline Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF17203A), Color(0xFF4A5670)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Text(
                'Helpline',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF0F4FA),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Contact Information Section
          buildHelplineCard('Emergency', '7357565529', Icons.phone, Colors.red),
          SizedBox(height: 20),
          buildHelplineCard('Feedback', 'b23093@students.iitmandi.ac.in',
              Icons.email, Colors.orange),
          SizedBox(height: 30),

          // Contact Support Button at the bottom center
          Center(
            child: GestureDetector(
              onTap: () {
                // Handle Contact Support action
              },
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Color(0xFF17203A), Color(0xFF4A5670)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to create helpline cards with contact info and icons
  Widget buildHelplineCard(
      String title, String contact, IconData icon, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 30),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17203A),
                ),
              ),
              Text(
                contact,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A5670),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
