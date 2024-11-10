import 'package:flutter/material.dart';
import 'signup.dart'; // Importing the signup page

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  WelcomeState createState() => WelcomeState();
}

class WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        // Allow scrolling for small screens
        child: Stack(
          children: [
            // Background Gradient
            Container(
              height: screenHeight, // Use full height
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9096B8),
                    Color(0xFF17203A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.1, left: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IIT Logo
                    Center(
                      child: Image.asset(
                        'assets/images/iitLogo.png', // Replace with your image path
                        width: screenWidth * 0.4, // Responsive width
                        height: screenHeight * 0.2, // Responsive height
                      ),
                    ),
                    SizedBox(
                        height: screenHeight *
                            0.04), // Space between image and text

                    // Welcome Text
                    Center(
                      child: Text(
                        'Greetings, Traveler!',
                        style: TextStyle(
                          fontSize: screenWidth * 0.08, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: const Color(
                              0xFFF0F4FA), // White text for contrast
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Non-scrollable content with rounded top container
            Padding(
              padding:
                  EdgeInsets.only(top: screenHeight * 0.4), // Dynamic padding
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    SizedBox(
                        height: screenHeight * 0.03), // Space above the title
                    // Title Text
                    Text(
                      'Welcome to Seamless Travel',
                      style: TextStyle(
                        fontSize: screenWidth * 0.06, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        height: screenHeight *
                            0.02), // Space between the text and the image

                    // Bus Image below introduction text
                    Image.asset(
                      "assets/images/buslogo.jpg", // Replace with your image path
                      width: screenWidth * 0.8, // Make image responsive
                      height: screenHeight * 0.3, // Responsive height
                      fit: BoxFit.cover, // Adjust to maintain aspect ratio
                    ),
                    SizedBox(
                        height: screenHeight * 0.05), // Space before button

                    // Introductory Text before button
                    Text(
                      'Join us and explore the convenience of our bus service! Tap the Get Started button to begin.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Responsive font size
                        color: Colors.black54,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        height: screenHeight *
                            0.03), // Space between text and button

                    // 'Get Started' Button
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Signup page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const Signup()), // Navigate to Signup page
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.2,
                          vertical: screenHeight * 0.025,
                        ),
                        backgroundColor:
                            Colors.black, // Button background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045, // Responsive font size
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                        height: screenHeight *
                            0.05), // Padding at the bottom of the button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int hexColor(String c) {
  String sColor = '0xff$c';
  sColor = sColor.replaceAll('#', '');
  int dColor = int.parse(sColor);
  return dColor;
}
