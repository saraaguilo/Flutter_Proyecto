import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;


pickImage(ImageSource source) async {
  try {
    final ImagePicker _imagePicker = ImagePicker();
    final _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {

      return  _file;
    }
    print('No images Selected');
  } on PlatformException catch (e) {
    print('failed: $e');
  }
}



