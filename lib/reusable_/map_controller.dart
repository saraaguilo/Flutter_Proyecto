import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapController {
  final _mapTapController = StreamController<LatLng>.broadcast();

  Stream<LatLng> get mapTapStream => _mapTapController.stream;

  void handleMapTap(LatLng selectedLatLng, {bool creatingEvent = false}) {
    _mapTapController.add(selectedLatLng);

    if (creatingEvent) {
      // Realiza otras acciones específicas si estás creando un evento
      print('Creando un evento en el controlador.');
    }
  }

  void dispose() {
    _mapTapController.close();
  }
}
