import 'package:flutter/material.dart';

class Message2 {
  String message;
  String sentByMe;

  Message2({required this.message, required this.sentByMe});
  factory Message2.fromJson(Map<String, dynamic> json) {
  return Message2(message: json["message"], sentByMe: json["sentByMe"]);
  }
}