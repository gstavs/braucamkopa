// lib/my_tickets_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart'; // Or your models file (ensure customDarkerYellow and customDarkGrey are accessible from here if defined in main.dart)
import 'my_tickets_provider.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  Future<void> _pickImage(BuildContext context, MyTicket ticket) async {
    final myTicketsProvider = Provider.of<MyTicketsProvider>(context, listen: false);
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        myTicketsProvider.addImageToTicket(ticket.id, image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attēls veiksmīgi pievienots!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Neizdevās izvēlēties attēlu: $e')),
      );
    }
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nevarēja atvērt saiti: $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myTicketsProvider = Provider.of<MyTicketsProvider>(context);
    final tickets = myTicketsProvider.myTickets;
    final theme = Theme.of(context);

    if (tickets.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manas biļetes'),
          // backgroundColor: theme.appBarTheme.backgroundColor, // Inherits from theme
          // foregroundColor: theme.appBarTheme.foregroundColor, // Inherits from theme
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Jums vēl nav iegādātu biļešu.\nDodieties uz sākuma ekrānu, lai apskatītu pasākumus!',
              style: theme.textTheme.titleMedium?.copyWith(
                // Use a color that's visible but not too strong for this helper text
                color: theme.brightness == Brightness.light ? Colors.grey[600] : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manas biļetes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16.0), // Add padding at the bottom of the list
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          final event = ticket.event;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 4, // You might want to adjust elevation based on your overall theme design
            clipBehavior: Clip.antiAlias, // Ensures content respects card's shape
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy \'plkst.\' HH:mm', 'lv_LV').format(event.date),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Jūsu biļete:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (ticket.userUploadedImagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(ticket.userUploadedImagePath!),
                        height: 200, // Adjust height as needed
                        width: double.infinity,
                        fit: BoxFit.contain, // Use contain to see the whole ticket
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              height: 100,
                              color: theme.colorScheme.errorContainer.withOpacity(0.3),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 30),
                                  const SizedBox(height: 4),
                                  Text('Nevarēja ielādēt attēlu.', style: TextStyle(color: theme.colorScheme.error)),
                                ],
                              ),
                            ),
                      ),
                    )
                  else
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: theme.dividerColor)
                      ),
                      alignment: Alignment.center,
                      child: Text(
                          'Nav augšupielādēts attēls.',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.brightness == Brightness.light ? Colors.grey[700] : Colors.grey[400]
                          )
                      ),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(ticket.userUploadedImagePath == null ? Icons.upload_file : Icons.edit),
                    label: Text(ticket.userUploadedImagePath == null ? 'Augšupielādēt biļeti' : 'Mainīt attēlu'),
                    onPressed: () => _pickImage(context, ticket),
                    style: ElevatedButton.styleFrom(
                      // These will now inherit from your ElevatedButtonTheme in main.dart
                      // backgroundColor: theme.colorScheme.secondary, // Uses customYellow
                      // foregroundColor: theme.colorScheme.onSecondary, // Uses textOnYellow (customDarkGrey)
                        minimumSize: const Size(double.infinity, 40) // Make button wider
                    ),
                  ),
                  const Divider(height: 32),

                  Text('Informācija par mākslinieku:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                      'Šeit būs īss apraksts par ${event.name.split(" ")[0]}. Plašāka informācija pieejama internetā.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.light ? customDarkGrey : theme.textTheme.bodySmall?.color // Darker for light mode
                      )
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _launchURL(context, 'https://www.google.com/search?q=${Uri.encodeComponent(event.name)}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Meklēt Google par "${event.name}"',
                        style: TextStyle(
                          color: theme.brightness == Brightness.light ? customDarkerYellow : theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: theme.brightness == Brightness.light ? customDarkerYellow : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Informācija par norises vietu:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                      'Detalizētāka informācija par ${event.location} pieejama tiešsaistē.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.brightness == Brightness.light ? customDarkGrey : theme.textTheme.bodySmall?.color // Darker for light mode
                      )
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _launchURL(context, 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(event.location)}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Skatīt "${event.location}" kartē',
                        style: TextStyle(
                          color: theme.brightness == Brightness.light ? customDarkerYellow : theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: theme.brightness == Brightness.light ? customDarkerYellow : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Mūzika:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_fill),
                    label: Text('Meklēt ${event.name.split(" ")[0]} Spotify'),
                    onPressed: () {
                      _launchURL(context, 'https://open.spotify.com/search/${Uri.encodeComponent(event.name.split(" ")[0])}');
                    },
                    style: ElevatedButton.styleFrom(
                      // These will inherit from theme
                        minimumSize: const Size(double.infinity, 40)
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    label: Text('Dzēst šo biļeti', style: TextStyle(color: theme.colorScheme.error)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Apstiprināt dzēšanu'),
                            content: Text('Vai tiešām vēlaties dzēst biļeti pasākumam "${event.name}"?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Atcelt'),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Dzēst', style: TextStyle(color: theme.colorScheme.error)),
                                onPressed: () {
                                  myTicketsProvider.removeTicket(ticket.id);
                                  Navigator.of(dialogContext).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Biļete "${event.name}" dzēsta.')),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.error.withOpacity(0.7)), // Slightly more visible border
                        minimumSize: const Size(double.infinity, 40)
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
