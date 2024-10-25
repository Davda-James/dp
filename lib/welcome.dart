import 'package:flutter/material.dart';
import 'signup.dart'; // Importing the signup page

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  WelcomeState createState() => WelcomeState(); // Change made here
}

class WelcomeState extends State<Welcome> { // Change made here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff39C4D7),
                  Color(0xff087DA2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0, left: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IIT Logo
                  Center(
                    child: Image.asset(
                      'assets/images/iitLogo.png', // Replace with your image path
                      width: 175, // Specify width if needed
                      height: 125, // Specify height if needed
                    ),
                  ),
                  const SizedBox(height: 30), // Space between image and text

                  // Welcome Text
                  const Center(
                    child: Text(
                      'Greetings, Traveler!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // White text for contrast
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scrollable content with rounded top container
          Padding(
            padding: const EdgeInsets.only(top: 325.0),
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
                        child: Column(
                          children: [
                            const Text(
                              'Welcome to Seamless Travel',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center, // Center the text
                            ),
                            const SizedBox(height: 20), // Space between the text and the image

                            // Bus Image below introduction text
                            Image.asset(
                              "assets/images/buslogo.jpg", // Replace with your image path
                              width: MediaQuery.of(context).size.width * 0.8, // Make image responsive
                              height: MediaQuery.of(context).size.height * 0.3,
                              fit: BoxFit.cover, // Adjust to maintain aspect ratio
                            ),
                            const SizedBox(height: 40), // Pushes the button to the bottom

                            // Introductory Text before button
                            const Text(
                              'Join us and explore the convenience of our bus service! Tap the Get Started button to begin.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.center, // Center align the text
                            ),
                            const SizedBox(height: 30), // Space between text and button

                            // 'Get Started' Button
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to Signup page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Signup()), // Navigate to Signup page
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 17),
                                backgroundColor: Colors.black, // Button background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30), // Padding at the bottom of the button
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
