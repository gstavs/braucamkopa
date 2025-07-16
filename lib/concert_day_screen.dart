// lib/concert_day_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart'; // For MyTicket, Event
import 'ride_plan.dart'; // For RidePlan, Stop

// StopTimer class definition
class StopTimer {
  final bool isActive;
  final String? message;
  final DateTime? endTime;

  StopTimer({this.isActive = false, this.message, this.endTime});

  factory StopTimer.fromSnapshot(DataSnapshot snapshot) {
    if (snapshot.value == null || snapshot.value is! Map) return StopTimer();
    Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
    return StopTimer(
      isActive: map['isActive'] ?? false,
      message: map['message'] as String?,
      endTime: map['endTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int) : null,
    );
  }

  Duration? get remainingTime {
    if (isActive && endTime != null && endTime!.isAfter(DateTime.now())) {
      return endTime!.difference(DateTime.now());
    }
    return null;
  }
}

class ConcertDayScreen extends StatefulWidget {
  final MyTicket ticket;

  const ConcertDayScreen({super.key, required this.ticket});

  @override
  State<ConcertDayScreen> createState() => _ConcertDayScreenState();
}

class _ConcertDayScreenState extends State<ConcertDayScreen> {
  late DatabaseReference _timerRef;
  StopTimer _currentStopTimer = StopTimer();

  @override
  void initState() {
    super.initState();
    _timerRef = FirebaseDatabase.instance.ref('event_timers/${widget.ticket.event.id}');

    _timerRef.onValue.listen((DatabaseEvent event) {
      if (mounted && event.snapshot.exists) {
        setState(() {
          _currentStopTimer = StopTimer.fromSnapshot(event.snapshot);
        });
      } else if (mounted) {
        setState(() {
          _currentStopTimer = StopTimer();
        });
      }
    }, onError: (Object o) {
      print('Firebase Database Error in ConcertDayScreen: $o');
    });
  }

  String formatDuration(Duration? duration) {
    if (duration == null) return "00:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final Event event = widget.ticket.event;
    final RidePlan? ridePlan = event.ridePlan;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Koncerts šodien: ${event.name}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Timer Section
            if (_currentStopTimer.isActive && _currentStopTimer.endTime != null)
              Center(
                child: Card(
                  color: theme.colorScheme.surfaceVariant, // Changed for better visibility in light/dark
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          _currentStopTimer.message ?? "Pauzes taimeris!",
                          style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            final remaining = _currentStopTimer.remainingTime;
                            if (remaining != null && !remaining.isNegative) {
                              return Text(
                                formatDuration(remaining),
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            } else if (_currentStopTimer.isActive) {
                              return Text(
                                "Laiks beidzies!",
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: theme.colorScheme.error, // Use a distinct color
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 5),
                        if(_currentStopTimer.endTime != null)
                          Text(
                            "Atgriešanās pie transporta līdz: ${DateFormat('HH:mm').format(_currentStopTimer.endTime!)}",
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          )
                      ],
                    ),
                  ),
                ),
              ),

            Text("Brauciena plāns", style: theme.textTheme.headlineMedium),
            const SizedBox(height: 10),
            if (ridePlan == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Brauciena plāns šim pasākumam nav pieejams."),
              )
            else
              _buildRidePlanDetails(context, ridePlan, theme),

            const SizedBox(height: 30),
            Text("Norises vieta", style: theme.textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text("Adrese: ${event.location}", style: theme.textTheme.bodyLarge),
            const SizedBox(height: 10),
            // Placeholder for Offline Map
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300], // Example color
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 50, color: Colors.grey[700]),
                  const SizedBox(height: 10),
                  Text(
                    "Šeit būs bezsaistes karte\n(Implementācija nepieciešama)",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions),
              label: const Text('Navigācija uz norises vietu'),
              onPressed: () async {
                String query = Uri.encodeComponent(event.location);
                // Universal maps link that tries to open installed map apps or browser
                Uri mapsUrl = Uri.parse("geo:0,0?q=$query");
                // Fallback for web if geo intent fails or no app handles it
                Uri webMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

                try {
                  if (await canLaunchUrl(mapsUrl)) {
                    await launchUrl(mapsUrl);
                  } else if (await canLaunchUrl(webMapsUrl)) {
                    await launchUrl(webMapsUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nevarēja atvērt kartes aplikāciju.'))
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kļūda atverot kartes: $e'))
                  );
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRidePlanDetails(BuildContext context, RidePlan ridePlan, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlanRow(theme, Icons.play_circle_outline, "Izbraukšana:", "${ridePlan.startLocationName} plkst. ${ridePlan.departureTime.format(context)}"),
            if (ridePlan.generalNotes != null && ridePlan.generalNotes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 32.0, bottom: 8.0), // Indent notes
                child: Text("Piezīmes: ${ridePlan.generalNotes}", style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
              ),

            if (ridePlan.stops.isNotEmpty) ...[
              const Divider(height: 20, thickness: 1),
              Text("Plānotās pieturas:", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              for (var stop in ridePlan.stops) ...[
                _buildPlanRow(theme, Icons.pin_drop_outlined, stop.name, "${stop.locationAddress} ap plkst. ${stop.time.format(context)}"),
                if (stop.notes != null && stop.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0, left: 32.0),
                    child: Text("Piezīmes: ${stop.notes}", style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                  ),
              ],
            ],
            const Divider(height: 20, thickness: 1),
            _buildPlanRow(theme, Icons.flag_outlined, "Ierašanās norises vietā:", "${ridePlan.arrivalVenueName} ap plkst. ${ridePlan.estimatedArrivalTimeAtVenue.format(context)}"),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanRow(ThemeData theme, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

