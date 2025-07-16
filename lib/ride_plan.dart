// lib/ride_plan.dart
import 'package:flutter/material.dart'; // For TimeOfDay

class Stop {
  final String name;
  final String locationAddress;
  final TimeOfDay time;
  final String? notes;

  Stop({
    required this.name,
    required this.locationAddress,
    required this.time,
    this.notes,
  });
}

class RidePlan {
  final String id; // Matches Event ID
  final String startLocationName;
  final TimeOfDay departureTime;
  final List<Stop> stops;
  final String arrivalVenueName;
  final TimeOfDay estimatedArrivalTimeAtVenue;
  final String? generalNotes;
  // Potentially add fields for map coordinates or map image URL

  RidePlan({
    required this.id,
    required this.startLocationName,
    required this.departureTime,
    this.stops = const [],
    required this.arrivalVenueName,
    required this.estimatedArrivalTimeAtVenue,
    this.generalNotes,
  });

  factory RidePlan.dummy(String eventId) {
    bool isTodayEvent = eventId.contains("today"); // Simple check based on dummy ID
    return RidePlan(
      id: eventId,
      startLocationName: isTodayEvent ? "Rīga, Autoosta" : "Centrālā stacija, Liepāja",
      departureTime: isTodayEvent ? const TimeOfDay(hour: 12, minute: 30) : const TimeOfDay(hour: 14, minute: 0),
      stops: [
        Stop(
            name: "Pauze Kafejnīcā 'Pie Jāņa'",
            locationAddress: "A9 šoseja, km 56",
            time: isTodayEvent ? const TimeOfDay(hour: 14, minute: 00) : const TimeOfDay(hour: 15, minute: 30),
            notes: "Ātra kafija un uzkodas"),
        Stop(
            name: "Degvielas uzpilde",
            locationAddress: isTodayEvent ? "Circle K, Bauska" : "Circle K, Jelgava",
            time: isTodayEvent ? const TimeOfDay(hour: 15, minute: 30) : const TimeOfDay(hour: 17, minute: 00)),
      ],
      arrivalVenueName: isTodayEvent ? "Kauņas Žalgiris Arēna" : "Arēna Rīga", // Added a default value for non-today events
      estimatedArrivalTimeAtVenue: isTodayEvent ? const TimeOfDay(hour: 17, minute: 00) : const TimeOfDay(hour: 19, minute: 00), // Added a default value
      generalNotes: isTodayEvent ? "Neaizmirstiet biļetes!" : "Saglabājiet labu garastāvokli!", // Added a default value
    );
  }
}
