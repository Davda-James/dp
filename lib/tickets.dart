import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

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

class UserTicketsPageContent extends StatefulWidget {
  final String userId;

  UserTicketsPageContent({required this.userId});
  @override
  _UserTicketsPageContentState createState() => _UserTicketsPageContentState();
}

class _UserTicketsPageContentState extends State<UserTicketsPageContent> {
  late Future<List<Map<String, dynamic>>> _ticketsFuture;
  List<Map<String, dynamic>> _tickets = [];

  int? _expandedIndex;
  @override
  void initState() {
    super.initState();
    _ticketsFuture = fetchUserTickets();
  }

  Future<List<Map<String, dynamic>>> fetchUserTickets() async {
    try {
      // Fetch tickets from UserBookings collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UserBookings')
          .doc(widget.userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        List<dynamic> bookedSeats = userDoc['bookedSeats'];
        return bookedSeats.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      _showErrorDialog(context, "Error fetching tickets");
      return [];
    }
  }

  Future<void> cancelTicket(Map<String, dynamic> ticket) async {
    try {
      // Reference to the Bookings collection
      final bookingsCollectionRef =
          FirebaseFirestore.instance.collection('Bookings');

      // Query to find the document with the matching busId, route, date, and timing
      final querySnapshot = await bookingsCollectionRef
          .where('busId', isEqualTo: ticket['busId'])
          .where('route', isEqualTo: ticket['route'])
          .where('date', isEqualTo: ticket['date'])
          .where('timing', isEqualTo: ticket['timing'])
          .get();

      // If we find the matching document, proceed
      if (querySnapshot.docs.isNotEmpty) {
        // Loop through each document (there might be multiple matching docs)
        for (var doc in querySnapshot.docs) {
          // Get the bookedSeats map for the current document
          Map<String, dynamic> bookedSeats =
              Map<String, dynamic>.from(doc['bookedSeats']);

          // Check if the seatNo exists in the bookedSeats map for the current user
          if (bookedSeats.containsKey(ticket['seatNo'].toString())) {
            // If the seatNo matches, remove the seatNo key
            bookedSeats.remove(ticket['seatNo'].toString());

            // Update the bookedSeats map in the current document
            await doc.reference.update({'bookedSeats': bookedSeats});

            // Now remove the ticket from the user's bookedSeats in UserBookings
            final userDocRef = FirebaseFirestore.instance
                .collection('UserBookings')
                .doc(widget.userId);
            DocumentSnapshot userDoc = await userDocRef.get();

            if (userDoc.exists && userDoc.data() != null) {
              List<dynamic> bookedSeatsList = List.from(userDoc['bookedSeats']);
              bookedSeatsList.removeWhere((seat) =>
                  seat['busId'] == ticket['busId'] &&
                  seat['seatNo'] == ticket['seatNo'] &&
                  seat['route'] == ticket['route'] &&
                  seat['date'] == ticket['date'] &&
                  seat['timing'] == ticket['timing']);

              // Update the user's bookedSeats list
              await userDocRef.update({'bookedSeats': bookedSeatsList});

              // Remove the canceled ticket from the list and show success dialog
              setState(() {
                _tickets.remove(ticket);
              });

              _showSuccessDialog(context);
              return;
            }
          }
        }
      } else {
        _showErrorDialog(context, "No matching ticket found");
      }
    } catch (e) {
      _showErrorDialog(context, "Error cancelling ticket");
    }
  }

  void _showSuccessDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Ticket Cancelled',
      desc: 'Your ticket has been successfully cancelled.',
      btnOkOnPress: () {},
    ).show();
  }

  void _showErrorDialog(BuildContext context, String error) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Error',
      desc: 'Failed to cancel the ticket.\n$error',
      btnOkOnPress: () {},
    ).show();
  }

  void _showCancelBottomSheet(
      BuildContext context, Map<String, dynamic> ticket) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cancel Ticket',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Are you sure you want to cancel this ticket?',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.cancel),
              label: Text('Cancel Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              onPressed: () {
                Navigator.pop(context); // Close the bottom sheet
                cancelTicket(ticket); // Perform cancellation
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, int index) {
    final qrCodeBase64 = ticket['qrCodeBase64'];
    final qrBytes = qrCodeBase64 != null ? base64Decode(qrCodeBase64) : null;

    return GestureDetector(
      onTap: () {
        _showCancelBottomSheet(context, ticket);
      },
      child: Card(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading tickets.'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            _tickets = snapshot.data!;
            return ListView.builder(
              itemCount: _tickets.length,
              itemBuilder: (context, index) {
                return _buildTicketCard(_tickets[index], index);
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
