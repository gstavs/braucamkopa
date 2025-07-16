// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages Import for image_picker (can be removed if not directly used in main)
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages Import for url_launcher (can be removed if not directly used in main)
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';
import 'settings_screen.dart';
import 'theme_provider.dart';
import 'login_screen.dart'; // For currentUserEmailForTesting and navigation
import 'my_tickets_provider.dart';
import 'my_tickets_screen.dart';
import 'ride_plan.dart';
import 'concert_day_screen.dart';

// YOUR DEFINED COLORS
const Color customWhite = Color(0xFFE4E4E4);
const Color customDarkGrey = Color(0xFF4A4A4A);
const Color customYellow = Color(0xFFE6BF70);
const Color customDarkerYellow = Color(0xFF8A3242); // Example: A darker shade of your yellow


// DERIVED/ADDITIONAL COLORS FOR PROFESSIONAL UI
const Color textOnWhite = Color(0xFF1F1F1F); // Very dark grey, almost black, for text on white background
const Color textOnDarkGrey = Color(0xFFFFFFFF); // White text for on your #333333 bars
const Color textOnYellow = Color(0xFF333333);   // Dark grey text for on your #E6BF70 buttons (good contrast)
const Color secondaryTextOnWhite = Color(0xFF757575); // Medium grey for less important text or icons on white


// Event class definition
class Event {
  final String id;
  final String name;
  final String location;
  final DateTime date;
  final String imageUrl;
  final String description;
  final RidePlan? ridePlan;

  Event({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.description,
    this.ridePlan,
  });
}

// MyTicket class definition
class MyTicket {
  final String id;
  final Event event;
  String? userUploadedImagePath;

  MyTicket({
    required this.id,
    required this.event,
    this.userUploadedImagePath,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('lv_LV', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MyTicketsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Flutter Event App',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: customWhite, // Main background: #FFFFFF

        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: customYellow,        // Accent color: #E6BF70
          onPrimary: textOnYellow,      // Text/icons on accent buttons: #333333
          secondary: customYellow,      // Can be the same as primary or a different accent
          onSecondary: textOnYellow,    // Text/icons on secondary accent
          background: customWhite,      // App background: #FFFFFF
          onBackground: textOnWhite,    // Main text on white background: #1F1F1F
          surface: customWhite,         // Card/Dialog background: #FFFFFF
          onSurface: textOnWhite,       // Text on cards/dialogs: #1F1F1F
          error: Colors.redAccent,      // Standard error color
          onError: customWhite,         // Text on error color (usually white)
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: customDarkGrey, // AppBar background: #333333
          foregroundColor: textOnDarkGrey, // Title/icons on AppBar: #FFFFFF
          elevation: 1.0,                 // Subtle shadow for depth
          iconTheme: IconThemeData(color: textOnDarkGrey),
          actionsIconTheme: IconThemeData(color: textOnDarkGrey),
          titleTextStyle: TextStyle(
            color: textOnDarkGrey,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: customDarkGrey,          // BottomNav background: #333333
          selectedItemColor: customYellow,          // Selected item (accent): #E6BF70
          unselectedItemColor: Colors.grey[400],    // Unselected item: A lighter grey for contrast on dark bar
          // (Colors.grey[400] is `0xFFBDBDBD`)
          // You could also use a semi-transparent white: textOnDarkGrey.withOpacity(0.7)
          elevation: 2.0,                           // Subtle shadow
        ),

        cardTheme: CardThemeData(
          color: customWhite, // Card background: #FFFFFF
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // side: BorderSide(color: Colors.grey[200]!, width: 0.5), // Optional: very light border
          ),
        ),

        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textOnWhite, fontSize: 16),
          bodyMedium: TextStyle(color: secondaryTextOnWhite, fontSize: 14),
          headlineSmall: TextStyle(color: textOnWhite, fontWeight: FontWeight.bold, fontSize: 24),
          titleLarge: TextStyle(color: textOnWhite, fontWeight: FontWeight.bold, fontSize: 20), // For screen titles
          titleMedium: TextStyle(color: textOnWhite, fontWeight: FontWeight.w600, fontSize: 18), // For card titles
          titleSmall: TextStyle(color: secondaryTextOnWhite, fontWeight: FontWeight.w500, fontSize: 16),
          // Button text is derived from onPrimary by default for ElevatedButton
          labelLarge: TextStyle(color: textOnYellow, fontWeight: FontWeight.bold, fontSize: 16), // Specifically for text on accent buttons
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: customYellow, // Button background (accent): #E6BF70
            foregroundColor: textOnYellow, // Button text/icon color: #333333
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100], // Light fill for text fields (e.g., #F5F5F5) for subtle contrast
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none, // No border by default if using fill
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: customYellow, width: 2), // Accent border when focused
          ),
          hintStyle: TextStyle(color: Colors.grey[500]), // e.g., #9E9E9E
          labelStyle: TextStyle(color: secondaryTextOnWhite), // #757575
        ),

        iconTheme: IconThemeData(
          color: secondaryTextOnWhite, // Default icon color for less prominent icons: #757575
        ),

        dividerColor: Colors.grey[300], // For subtle dividers (e.g., #E0E0E0)
        hintColor: secondaryTextOnWhite, // For hint icons like location, calendar in cards etc.

      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // Instead of primarySwatch, we'll define colors more explicitly
        // using ColorScheme for better control with custom hex codes.

        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: const Color(0xFFE6BF70), // Your primary accent color
          onPrimary: const Color(0xFF333333), // Text/icons on primary color

          secondary: const Color(0xFFE6BF70), // Can be same as primary or different
          onSecondary: const Color(0xFF333333),// Text/icons on secondary color

          background: const Color(0xFF333333), // Your main background color
          onBackground: const Color(0xFFFFFFFF),// Text/icons on background color

          surface: Color(0xFF424242), // A slightly lighter dark for surfaces like cards (adjust as needed, e.g. a darker shade of #333333 or a new hex)
          onSurface: const Color(0xFFFFFFFF),  // Text/icons on surface color

          error: Colors.redAccent, // Or your custom error color
          onError: Colors.white,
        ),

        scaffoldBackgroundColor: const Color(0xFF333333), // Using your #333333 for scaffold

        appBarTheme: AppBarTheme(
          elevation: 1,
          backgroundColor: const Color(0xFF333333), // AppBar background
          foregroundColor: const Color(0xFFE6BF70), // AppBar title/icons
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFF424242), // Example: A slightly different shade for cards
          // If you want cards to be #333333 as well, use Color(0xFF333333)
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),    // Text on #333333 background
          bodyMedium: TextStyle(color: Color(0xAAFFFFFF)), // Slightly transparent white for less emphasis
          titleLarge: TextStyle(color: Color(0xFFE6BF70)),   // Titles could use your accent color
          headlineSmall: TextStyle(color: Color(0xFFE6BF70)),// Headlines as well
          titleMedium: TextStyle(color: Color(0xFFFFFFFF)),
          titleSmall: TextStyle(color: Color(0xAAFFFFFF)),
          // Ensure other text styles are defined if needed
        ),

        // You might also want to theme other components:
        // elevatedButtonTheme: ElevatedButtonThemeData(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: const Color(0xFFE6BF70), // Button background
        //     foregroundColor: const Color(0xFF333333), // Button text
        //   ),
        // ),
        // bottomNavigationBarTheme: BottomNavigationBarThemeData(
        //   backgroundColor: const Color(0xFF333333),
        //   selectedItemColor: const Color(0xFFE6BF70),
        //   unselectedItemColor: Colors.grey[500],
        // ),
        // iconTheme: IconThemeData(
        //  color: const Color(0xFFE6BF70) // Default icon color
        // )
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );

  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = []; // Initialize as empty
  List<BottomNavigationBarItem> _navBarItems = []; // Initialize as empty
  bool _showConcertDayTab = false;

  bool get isAdmin {
    return currentUserEmailForTesting == "admin@test.com";
  }

  @override
  void initState() {
    super.initState();
    _buildNavigationOptions(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final myTicketsProvider = Provider.of<MyTicketsProvider>(context);
    final newShowConcertDayTab = myTicketsProvider.hasConcertToday();

    bool adminTabCurrentlyExists = _navBarItems.any((item) => item.label == 'Admin');
    bool needsAdminStatusCheck = adminTabCurrentlyExists != isAdmin;

    if (_showConcertDayTab != newShowConcertDayTab || needsAdminStatusCheck) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showConcertDayTab = newShowConcertDayTab;
            _buildNavigationOptions(newShowConcertDayTab);
          });
        }
      });
    } else if (_widgetOptions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _buildNavigationOptions(newShowConcertDayTab);
          });
        }
      });
    }
  }

  void _buildNavigationOptions(bool showConcertTab) {
    final myTicketsProvider = Provider.of<MyTicketsProvider>(context, listen: false);
    _showConcertDayTab = showConcertTab;
    final bool currentAdminStatus = isAdmin;

    final List<Widget> tempWidgetOptions = [
      HomeScreen(), // Index 0
      const MyTicketsScreen(), // Index 1
    ];
    final List<BottomNavigationBarItem> tempNavBarItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Sākums',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.confirmation_num),
        label: 'Manas biļetes',
      ),
    ];

    if (_showConcertDayTab && myTicketsProvider.todaysConcertTicket != null) {
      tempWidgetOptions.add(ConcertDayScreen(ticket: myTicketsProvider.todaysConcertTicket!));
      tempNavBarItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.event_seat_sharp),
        label: 'Koncerts',
      ));
    }

    if (currentAdminStatus) {
      tempWidgetOptions.add(const AdminPanelScreen());
      tempNavBarItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings),
        label: 'Admin',
      ));
    }

    tempWidgetOptions.add(const SettingsScreen());
    tempNavBarItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Iestatījumi',
    ));

    _widgetOptions = List.unmodifiable(tempWidgetOptions);
    _navBarItems = List.unmodifiable(tempNavBarItems);

    if (_selectedIndex >= _widgetOptions.length) {
      _selectedIndex = _widgetOptions.length - 1;
    }
    if (_selectedIndex < 0 && _widgetOptions.isNotEmpty) {
      _selectedIndex = 0;
    } else if (_widgetOptions.isEmpty) {
      _selectedIndex = 0;
    }
  }

  void _onItemTapped(int index) {
    if (index >= 0 && index < _navBarItems.length) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted){
          setState(() {
            _buildNavigationOptions(Provider.of<MyTicketsProvider>(context, listen: false).hasConcertToday());
            _selectedIndex = (index >= 0 && index < _navBarItems.length) ? index : 0;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_widgetOptions.isEmpty || _navBarItems.isEmpty) {
      _buildNavigationOptions(Provider.of<MyTicketsProvider>(context, listen: false).hasConcertToday());
      if (_widgetOptions.isEmpty) {
        return const Scaffold(body: Center(child: CircularProgressIndicator(key: ValueKey("loadingNav"))));
      }
    }

    int currentMaxIndex = _widgetOptions.length - 1;
    if (_selectedIndex > currentMaxIndex && currentMaxIndex >= 0) {
      _selectedIndex = currentMaxIndex;
    } else if (currentMaxIndex < 0 && _widgetOptions.isNotEmpty) {
      _selectedIndex = 0;
    } else if (_widgetOptions.isEmpty){
      return const Scaffold(body: Center(child: Text("Navigācija netiek ielādēta...")));
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navBarItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  static final List<Event> eventsData = [
    Event(
      id: 'event1_acdc',
      name: 'AC/DC PWR UP Tour',
      location: 'Tallina, Igaunija',
      date: DateTime(2025, 7, 24, 20, 0),
      imageUrl: 'https://braucamkopa.lv/wp-content/uploads/2025/02/ACDC-SQUARE.webp',
      description: 'AC/DC koncerts Tallinā – piedzīvo leģendāro rokenrola šovu! Rokenrola leģendas AC/DC 2025. gada 24. jūlijā uzstāsies Tallinas Dziesmu svētku estrādē, piedāvājot faniem neaizmirstamu vakaru ar saviem ikoniskajiem hitiem un elektrizējošo skatuves enerģiju. Šī ir unikāla iespēja redzēt vienu no visu laiku ietekmīgākajām rokgrupām dzīvajā – pieredzēt “Thunderstruck”, “Back in Black”, “Highway to Hell”, “You Shook Me All Night Long” un daudzus citus leģendāros skaņdarbus!',
      ridePlan: RidePlan.dummy('event1_acdc'),
    ),
    Event(
      id: 'event2_postmalone_today',
      name: 'Post Malone World Tour',
      location: 'Kauņa, Lietuva',
      date: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21, 0), // Today for testing!
      imageUrl: 'https://braucamkopa.lv/wp-content/uploads/2025/03/square.webp',
      description: "Post Malone Eiropas turneja 2025: Neaizmirstams koncerts Baltijā! Globālā superzvaigzne un deviņkārtējais dimanta statusa ieguvējs Post Malone 2025. gada augustā un septembrī dosies savā līdz šim vērienīgākajā koncerttūrē – “Post Malone Presents: The BIG ASS World Tour”. Šī būs viņa pirmā stadionu turneja Eiropā, piedāvājot grandiozus šovus 11 lielākajos stadionos visā kontinentā.",
      ridePlan: RidePlan(
          id: 'event2_postmalone_today',
          startLocationName: "Autobuss no Spice",
          departureTime: const TimeOfDay(hour: 15, minute: 0),
          stops: [
            Stop(name: "Pietura pie robežas", locationAddress: "LV/LT Robeža", time: const TimeOfDay(hour: 17, minute: 30), notes: "Dokumentu pārbaude"),
          ],
          arrivalVenueName: "Kauņas Žalgiris Arēna",
          estimatedArrivalTimeAtVenue: const TimeOfDay(hour: 19, minute: 30),
          generalNotes: "Jautri pavadām laiku!"),
    ),
    Event(
      id: 'event3_future_concert',
      name: 'Future Fest 2026',
      location: 'Ventspils, Latvija',
      date: DateTime(2026, 6, 15, 18, 0),
      imageUrl: 'https://via.placeholder.com/400x225.png?text=Future+Fest',
      description: "Nākotnes mūzikas festivāls Ventspilī.",
      ridePlan: RidePlan.dummy('event3_future_concert'),
    ),
  ];

  final List<Event> events = eventsData;

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String userName = currentUserEmailForTesting?.split('@').first ?? "lietotāj";
    userName = userName[0].toUpperCase() + userName.substring(1);
    Color titleColor = Theme.of(context).textTheme.titleLarge?.color ??
        (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black);

    const double logoSize = 40.0; // Adjusted logo size for better balance

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: false, // AppBar is NOT sticky
            floating: true, // Optional: AppBar reappears when scrolling up
            snap: true,     // Optional: Snaps AppBar into view when floating
            expandedHeight: 40.0, // Adjust to fit logo and text comfortably.
            // This effectively becomes the height of the AppBar.
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            actions: const [], // No actions on the right
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0.0), // Minimal vertical padding for the title content
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Align to the left
                crossAxisAlignment: CrossAxisAlignment.center, // Vertically center items
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.0),
                    child: Image.asset(
                      'assets/images/square.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12), // Space between logo and text
                  Expanded(
                    child: Text(
                      'Sveiki, $userName!',
                      style: TextStyle(
                        fontSize: 22, // Adjust as needed
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final hintColor = theme.hintColor;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
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
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.broken_image, color: Colors.grey[600], size: 50),
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
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: hintColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: textTheme.bodyMedium?.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: hintColor),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('EEE, MMM d, yyyy \'plkst.\' HH:mm', 'lv_LV').format(event.date),
                        style: textTheme.bodyMedium?.copyWith(fontSize: 14),
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

class EventDetailScreen extends StatelessWidget {
  final Event event;
  const EventDetailScreen({super.key, required this.event});

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nevarēja atvērt saiti: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    event.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: Icon(Icons.broken_image, size: 100, color: theme.disabledColor)),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              event.name,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: theme.hintColor),
                const SizedBox(width: 8),
                Expanded(child: Text(event.location, style: textTheme.bodyLarge)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: theme.hintColor),
                const SizedBox(width: 8),
                Text(DateFormat('EEEE, MMMM d, yyyy \'plkst.\' HH:mm', 'lv_LV').format(event.date),
                    style: textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Par koncertu:',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(event.description, style: textTheme.bodyLarge?.copyWith(height: 1.5)),
            const SizedBox(height: 20),
            if (event.ridePlan?.generalNotes?.contains("braucamkopa.lv") ?? false)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: InkWell(
                  onTap: () => _launchURL(context, "https://braucamkopa.lv"),
                  child: Text(
                    "Vairāk informācijas un biļetes: braucamkopa.lv",
                    style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final myTicketsProvider = Provider.of<MyTicketsProvider>(context, listen: false);
                  myTicketsProvider.addTicket(event);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${event.name} pievienots jūsu biļetēm!'),
                      action: SnackBarAction(
                        label: 'SKATĪT',
                        onPressed: () {
                          final homePageState = context.findAncestorStateOfType<_MyHomePageState>();
                          if (homePageState != null) {
                            int myTicketsIndex = homePageState._widgetOptions.indexWhere((widget) => widget is MyTicketsScreen);
                            if (myTicketsIndex != -1) {
                              homePageState._onItemTapped(myTicketsIndex);
                            } else {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Iegādāties'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  String? _selectedEventIdForTimer;
  final TextEditingController _timerMessageController = TextEditingController();
  final TextEditingController _timerDurationController = TextEditingController();

  final List<Event> _manageableEvents = HomeScreen.eventsData.where((event) {
    return event.date.isAfter(DateTime.now().subtract(const Duration(days: 1))) || DateUtils.isSameDay(event.date, DateTime.now());
  }).toList();

  void _startEventTimer(String eventId) {
    if (eventId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lūdzu izvēlieties pasākumu.')));
      return;
    }
    final message = _timerMessageController.text;
    final durationMinutes = int.tryParse(_timerDurationController.text);

    if (durationMinutes == null || durationMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lūdzu ievadiet derīgu ilgumu minūtēs.')));
      return;
    }
    final endTime = DateTime.now().add(Duration(minutes: durationMinutes));
    final timerData = {
      'isActive': true,
      'message': message.isNotEmpty ? message : "Pauze!",
      'endTime': endTime.millisecondsSinceEpoch,
    };

    FirebaseDatabase.instance.ref('event_timers/$eventId').set(timerData)
        .then((_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Taimeris pasākumam $eventId palaists!'))))
        .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kļūda palaižot taimeri: $error'))));

    _timerMessageController.clear();
    _timerDurationController.clear();
  }

  void _stopEventTimer(String eventId) {
    if (eventId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lūdzu izvēlieties pasākumu.')));
      return;
    }
    FirebaseDatabase.instance.ref('event_timers/$eventId').update({'isActive': false, 'message': 'Pauze beigusies'})
        .then((_) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Taimeris pasākumam $eventId apturēts.'))))
        .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kļūda apturot taimeri: $error'))));
  }

  @override
  void dispose() {
    _timerMessageController.dispose();
    _timerDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admina Panelis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pauzes taimera vadība', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            if (_manageableEvents.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Nav pieejamu pasākumu (šodienas vai nākotnes) taimera vadībai."),
              ),
            if (_manageableEvents.isNotEmpty)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Izvēlies pasākumu', border: OutlineInputBorder()),
                value: _selectedEventIdForTimer,
                hint: const Text('Atlasīt pasākumu'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEventIdForTimer = newValue;
                  });
                },
                items: _manageableEvents.map<DropdownMenuItem<String>>((Event event) {
                  return DropdownMenuItem<String>(
                    value: event.id,
                    child: Text("${event.name} (${DateFormat('dd.MM.yyyy').format(event.date)})"),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _timerMessageController,
              decoration: const InputDecoration(labelText: 'Taimera ziņojums (piem., Degvielas uzpilde)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timerDurationController,
              decoration: const InputDecoration(labelText: 'Ilgums (minūtēs)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Sākt taimeri'),
                  onPressed: _selectedEventIdForTimer == null ? null : () => _startEventTimer(_selectedEventIdForTimer!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('Apturēt taimeri'),
                  onPressed: _selectedEventIdForTimer == null ? null : () => _stopEventTimer(_selectedEventIdForTimer!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            // Placeholder for other admin functions
          ],
        ),
      ),
    );
  }
}
