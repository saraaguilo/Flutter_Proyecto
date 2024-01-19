class Event {
  final String id;
  final List<dynamic> coordinates;
  final DateTime date;
  final String eventName;
  final String description;
  final String? idUser;
  final List<String>? idComments;
  final String? photo;

  Event({
    required this.id,
    required this.coordinates,
    required this.date,
    required this.eventName,
    required this.description,
    this.idUser,
    this.idComments,
    this.photo,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String? parsedUserId;
    if (json['idUser'] != null) {
      parsedUserId = json['idUser'] is String ? json['idUser'] : json['idUser']['_id'];
    }
    return Event(
      id: json['_id'] ?? '',
      coordinates: json['coordinates'] != null
          ? List<dynamic>.from(json['coordinates'])
          : [],
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      eventName: json['eventName'] ?? '',
      description: json['description'] ?? '',
      idUser: parsedUserId,
      idComments: json['idComments'] != null
          ? List<String>.from(json['idComments'])
          : null,
      photo: json['photo'] ?? '',
    );
  }
}


/*

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

*/
