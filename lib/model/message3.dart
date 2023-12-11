import 'package:flutter/material.dart';

class Message3 {
  String message;
  String sentByMe;

  Message3({required this.message, required this.sentByMe});
  factory Message3.fromJson(Map<String, dynamic> json) {
  return Message3(message: json["message"], sentByMe: json["sentByMe"]);
  }
}