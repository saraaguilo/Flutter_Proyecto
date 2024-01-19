class Message {
  
  final List<String>? text;
  final String idUser;
  final String room;
  

  const Message({
    required this.text,
    required this.idUser,
    required this.room,
    
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      
      idUser: json['idUser'] ?? '',
      
      text: json['text'] != []
          ? List<String>.from(json['text'])
          : null,
      room: json['room'] ?? '',
      
    );
  }
}
