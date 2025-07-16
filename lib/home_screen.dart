// home_screen.dart (create this file)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting (add intl package to pubspec.yaml)

// Assuming you have your Event model in event_model.dart
// import 'event_model.dart'; // Uncomment if you create the model in a separate file

// Placeholder Event Model (if not using a separate file)
class Event {
  final String id;
  final String name;
  final String location;
  final DateTime date;
  final String imageUrl;
  final String description;

  Event({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.description,
  });
}
// ---

class HomeScreen extends StatelessWidget {
  // Sample event data (replace with your actual data source)
  final List<Event> events = [
    Event(
      id: '1',
      name: 'AC/DC PWR UP Tour',
      location: 'Tallina',
      date: DateTime(2025, 7, 24, 20, 0), // July 20, 2024, 6:00 PM
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Summer+Music+Fest', // Replace with actual image URL
      description: 'An amazing lineup of artists for a summer evening concert. Gates open at 5 PM.',
    ),
    Event(
      id: '2',
      name: 'Post Malone The Big Ass World Tour',
      location: 'Kauņa',
      date: DateTime(2025, 8, 21, 20, 0), // August 5, 2024, 8:00 PM
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Indie+Rock+Night',
      description: 'Discover the best new indie bands in town. Doors open at 7:30 PM.',
    ),
    Event(
      id: '3',
      name: 'Classical Evening',
      location: 'Grand Concert Hall',
      date: DateTime(2024, 9, 15, 19, 30), // September 15, 2024, 7:30 PM
      imageUrl: 'https://via.placeholder.com/600x400.png?text=Classical+Evening',
      description: 'Experience the beauty of classical music with renowned soloists and orchestra.',
    ),
  ];

  HomeScreen({super.key}); // Use super.key for constructors in modern Flutter

  @override
  Widget build(BuildContext context) {
    String userName = "Lietotāj!"; // Replace with actual user name logic if available

    return Scaffold( // Add Scaffold if HomeScreen is a top-level screen for this tab
      body: CustomScrollView( // Use CustomScrollView for more complex scroll effects
        slivers: <Widget>[
          SliverAppBar(
            pinned: false, // Set to true if you want the "Hi, User!" to stick
            expandedHeight: 100.0, // Adjust as needed
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              title: Text(
                'Sveiki, $userName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black, // Use theme color
                ),
              ),
              centerTitle: false, // Align to the start
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Match background
            elevation: 0, // Remove shadow if desired
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                final event = events[index];
                return EventCard(
                  event: event,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                );
              },
              childCount: events.length,
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        clipBehavior: Clip.antiAlias, // For rounded corners on the image
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Large Image (like Wolt)
            AspectRatio(
              aspectRatio: 16 / 9, // Common aspect ratio for images
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                // Add a loading builder for better UX
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                // Add an error builder for network issues or invalid URLs
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded( // Use Expanded to prevent overflow
                        child: Text(
                          event.location,
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('EEE, MMM d, yyyy \'at\' h:mm a').format(event.date), // Example: Tue, Jul 20, 2024 at 6:00 PM
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for Event Detail Screen
class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('More details for ${event.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(event.description),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement buy ticket logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Buy ticket for ${event.name} - functionality not implemented yet.')),
                  );
                },
                child: const Text('Buy Ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
