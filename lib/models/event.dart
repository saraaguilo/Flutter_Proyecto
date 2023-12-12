class Event {
  final String coordinates;
  final DateTime date;
  final String eventName;
  final String description;

  Event({
    required this.coordinates,
    required this.date,
    required this.eventName,
    required this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      coordinates: (json['coordinates'] as List<dynamic>).join(', '),
      date: DateTime.parse(json['date'] ?? ''),
      eventName: json['eventName'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
