// lib/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_provider.dart';
import 'login_screen.dart'; // For navigating back to login on logout
// Assuming your color constants are in main.dart or a constants file
// If customDarkGrey is in main.dart:
import 'main.dart'; // Import to access customDarkGrey (or your constants file)

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  // TODO: Replace with actual user data retrieval logic
  String get userName {
    // This should come from your auth state / user profile
    // For example, if passed via arguments or from a Provider
    return "Lietotājs";
  }

  String get userEmail {
    // This should also come from your auth state / user profile
    return "guest@example.com";
  }

  String? get userProfilePicUrl {
    // This should also come from your auth state / user profile
    return null; // Placeholder for no profile picture
  }

  Future<void> _logout() async {
    // TODO: Implement actual logout logic if you have session management
    // (e.g., clearing tokens, resetting user state in a Provider).
    print("Logout initiated. User is being navigated to LoginScreen.");

    if (mounted) {
      // Navigate to LoginScreen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false, // This predicate removes all routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // listen: true is default
    final theme = Theme.of(context); // Get the current theme data

    final String currentUserName = userName;
    final String currentUserEmail = userEmail;
    final String? currentUserProfilePicUrl = userProfilePicUrl;

    // The customDarkGrey should be defined in your main.dart or a theme constants file
    // and imported. For example:
    // const Color customDarkGrey = Color(0xFF333333); // Defined in main.dart

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iestatījumi'),
        // No automatic back button if this screen is a root of a BottomNavigationBar tab
        // If it can be pushed from elsewhere, AppBar might show a back button.
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.surfaceVariant, // Changed for better theme adaptability
                  backgroundImage: currentUserProfilePicUrl != null && currentUserProfilePicUrl.isNotEmpty
                      ? NetworkImage(currentUserProfilePicUrl)
                      : null,
                  child: currentUserProfilePicUrl == null || currentUserProfilePicUrl.isEmpty
                      ? Icon(
                    Icons.person,
                    size: 50,
                    color: theme.colorScheme.onSurfaceVariant, // Changed for better theme adaptability
                  )
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUserName,
                        style: theme.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUserEmail,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          SwitchListTile(
            secondary: Icon(Icons.notifications, color: theme.iconTheme.color), // Use themed icon color
            title: const Text('Paziņojumi'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications ${value ? "enabled" : "disabled"}')),
                );
              });
            },
          ),
          SwitchListTile(
            secondary: Icon(Icons.dark_mode, color: theme.iconTheme.color), // Use themed icon color
            title: const Text('Tumšais režīms'),
            value: themeProvider.isDarkMode(context), // Correctly calls isDarkMode
            onChanged: (bool value) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.edit,
              // Option 1: Match the text color (dark grey in light, onSurface in dark)
              color: theme.brightness == Brightness.light
                  ? customDarkGrey // Defined in main.dart or your constants file
                  : theme.colorScheme.onSurface,
              // Option 2: Keep it as primary accent (yellow)
              // color: theme.colorScheme.primary,
            ),
            title: Text(
              'Rediģēt profilu',
              style: TextStyle(
                color: theme.brightness == Brightness.light
                    ? customDarkGrey // Use customDarkGrey from your theme constants for light mode
                    : theme.colorScheme.onSurface, // Use a suitable contrast color for dark mode
              ),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigate to Edit Profile (not implemented)')),
              );
              // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: theme.colorScheme.error),
            title: Text('Izrakstīties', style: TextStyle(color: theme.colorScheme.error)),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Izrakstīties'),
                    content: const Text('Vai vēlaties izrakstīties?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Atcelt'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: Text('Jā', style: TextStyle(color: theme.colorScheme.error)),
                        onPressed: () {
                          Navigator.of(dialogContext).pop(); // Close the dialog
                          _logout(); // Perform the logout action
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20), // Some padding at the bottom
        ],
      ),
    );
  }
}
