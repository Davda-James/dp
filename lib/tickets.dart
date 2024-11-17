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
      final docRef = FirebaseFirestore.instance
          .collection('UserBookings')
          .doc(widget.userId);

      DocumentSnapshot userDoc = await docRef.get();

      if (userDoc.exists && userDoc.data() != null) {
        List<dynamic> bookedSeats = List.from(userDoc['bookedSeats']);
        bookedSeats.removeWhere((seat) =>
            seat['busId'] == ticket['busId'] &&
            seat['seatNo'] == ticket['seatNo'] &&
            seat['route'] == ticket['route'] &&
            seat['date'] == ticket['date'] &&
            seat['timing'] == ticket['timing']);

        await docRef.update({'bookedSeats': bookedSeats});
        _showSuccessDialog(context);
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

  // showing cancel bottom sheet
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

  // Building ticket card with expandable animation
  Widget _buildTicketCard(Map<String, dynamic> ticket, int index) {
    final isExpanded = _expandedIndex == index;
    final qrCodeBase64 = ticket['qrCodeBase64'];
    final qrBytes = qrCodeBase64 != null ? base64Decode(qrCodeBase64) : null;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? null : index; // Toggle expanded state
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                // QR Code (if available)
                if (qrBytes != null)
                  Image.memory(
                    qrBytes,
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  )
                else
                  const Text('QR Code not available'),
              ],
            ),
            // Expandable cancel button
            if (isExpanded) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.cancel),
                label: Text('Cancel Ticket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                ),
                onPressed: () {
                  _showCancelBottomSheet(context, ticket);
                },
              ),
            ],
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
                return _buildTicketCard(tickets[index], index);
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
