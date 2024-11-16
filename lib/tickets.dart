import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserTicketsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance
          .authStateChanges()
          .first, // Get the logged-in user
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()), // Show a loader
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text('Error: No logged-in user found'),
            ),
          );
        }

        final user = snapshot.data!;
        final userId = user.uid;

        return Scaffold(
          appBar: AppBar(title: Text('Your Tickets')),
          body: UserTicketsPageContent(userId: userId),
        );
      },
    );
  }
}

class UserTicketsPageContent extends StatelessWidget {
  final String userId;

  UserTicketsPageContent({required this.userId});

  Future<List<Map<String, dynamic>>> fetchUserTickets() async {
    try {
      // Fetch tickets from UserBookings collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UserBookings')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        List<dynamic> bookedSeats = userDoc['bookedSeats'];
        return bookedSeats.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print("Error fetching tickets: $e");
      return [];
    }
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final qrCodeBase64 = ticket['qrCodeBase64'];
    final qrBytes = qrCodeBase64 != null ? base64Decode(qrCodeBase64) : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Ticket Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bus ID: ${ticket['busId']}',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Seat No: ${ticket['seatNo']}',
                    style: GoogleFonts.roboto(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Route: ${ticket['route']}',
                    style: GoogleFonts.roboto(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Date: ${ticket['date']}',
                    style: GoogleFonts.roboto(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Timing: ${ticket['timing']}',
                    style: GoogleFonts.roboto(fontSize: 13),
                  ),
                ],
              ),
            ),
            // Right side: QR Code
            qrBytes != null
                ? Image.memory(
                    qrBytes,
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  )
                : const Text('QR Code not available'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUserTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading tickets.'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final tickets = snapshot.data!;
            return ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                return _buildTicketCard(tickets[index]);
              },
            );
          } else {
            return const Center(child: Text('No tickets found.'));
          }
        },
      ),
    );
  }
}
