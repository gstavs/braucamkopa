// event_model.dart (create this file if you don't have one)
class Event {
  final String id;
  final String name;
  final String location;
  final DateTime date;
  final String imageUrl; // URL or local asset path for the image
  final String description; // For the detail page

  Event({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.description,
  });
}
