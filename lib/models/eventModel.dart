class Event {
  final int id;
  final String imageUrl;
  final String title;
  final String date;
  final String eventType;
  final String location;

  Event({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.eventType,
    required this.location,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      imageUrl: json['image_url'],
      title: json['title'],
      date: json['date'],
      eventType: json['event_type'],
      location: json['location'],
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, title: $title, date: $date, location: $location, imageUrl: $imageUrl}';
  }
}
