// lib/my_tickets_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // For DateUtils
import 'main.dart'; // Or your models file if MyTicket and Event are there

class MyTicketsProvider with ChangeNotifier {
  final List<MyTicket> _myTickets = [];

  List<MyTicket> get myTickets => List.unmodifiable(_myTickets);

  void addTicket(Event event) {
    if (!_myTickets.any((ticket) => ticket.event.id == event.id)) {
      final newTicket = MyTicket(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        event: event,
      );
      _myTickets.add(newTicket);
      print("Ticket added: ${event.name}. Total tickets: ${_myTickets.length}");
      print("Is there a concert today? ${hasConcertToday()}");
      notifyListeners();
    } else {
      print("Ticket for ${event.name} already exists.");
    }
  }

  void addImageToTicket(String ticketId, String imagePath) {
    final ticketIndex = _myTickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex != -1) {
      _myTickets[ticketIndex].userUploadedImagePath = imagePath;
      notifyListeners();
    }
  }

  void removeTicket(String ticketId) {
    _myTickets.removeWhere((ticket) => ticket.id == ticketId);
    notifyListeners();
  }

  // Helper to check if there's a concert today for the current user
  bool hasConcertToday() {
    final today = DateTime.now();
    bool result = _myTickets.any((ticket) {
      return DateUtils.isSameDay(ticket.event.date, today);
    });
    // print("Checking hasConcertToday: $result");
    return result;
  }

  // Get the event for today if it exists (assuming one concert per day for simplicity)
  MyTicket? get todaysConcertTicket {
    final today = DateTime.now();
    try {
      MyTicket ticket = _myTickets.firstWhere(
              (ticket) => DateUtils.isSameDay(ticket.event.date, today));
      // print("Found today's concert ticket: ${ticket.event.name}");
      return ticket;
    } catch (e) {
      // print("No concert ticket found for today.");
      return null;
    }
  }

// TODO: Implement persistence (e.g., using shared_preferences or a database)
}
