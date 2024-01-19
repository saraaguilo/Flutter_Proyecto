class Chat {
  final String photo;
  final String groupName;
  final List<String>? idParticipants;
  final List<String>? idMessages;
  final String idEvent;
  

  const Chat({
    required this.photo,
    required this.groupName,
    this.idParticipants,
    this.idMessages,
    required this.idEvent,
    
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      photo: json['photo'] ?? '',
      groupName: json['groupName'] ?? '',
      idParticipants: json['idParticipants'] != []
          ? List<String>.from(json['idParticipants'])
          : null,
      idMessages: json['idMessages'] != []
          ? List<String>.from(json['idMessages'])
          : null,
      idEvent: json['idEvent'] ?? 'id',
      
    );
  }
}
