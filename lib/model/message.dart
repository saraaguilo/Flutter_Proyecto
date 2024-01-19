import 'package:flutter/material.dart';

class Message {
  String message;
  String sentByMe;

  var room;

  Message({required this.message, required this.sentByMe});
  factory Message.fromJson(Map<String, dynamic> json) {
  return Message(message: json["message"], sentByMe: json["sentByMe"]);
  }
}