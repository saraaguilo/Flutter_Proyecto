import 'package:applogin/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloudinary/cloudinary.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> uploadImage(cloudinary, imageAndroidPath, imageBytes, userName,
    email, password, idUser, token) async {
  try {
    CloudinaryResponse response;

    if (imageBytes != null && kIsWeb) {
      response = await cloudinary!.upload(
        fileBytes: imageBytes,
        resourceType: CloudinaryResourceType.image,
        folder: 'profilePics',
      );
      if (response.isSuccessful) {
        print('Get your image from with ${response.secureUrl}');

        final Map<String, String> userData = {
          'avatar': response.secureUrl ?? '',
          'userName': userName,
          'email': email,
          'password': password,
        };

        final response2 = await http.put(
          Uri.parse('$uri/users/$idUser'),
          headers: {'x-access-token': token},
          body: userData,
        );

        if (response2.statusCode == 201) {
          print('Perfil modificado con éxito.');
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('avatar', response.secureUrl ?? '');
        }
      } else {
        print('Not uploaded correctly');
      }
    } else if (imageAndroidPath != null && !kIsWeb) {
      response = await cloudinary!.upload(
        file: imageAndroidPath,
        resourceType: CloudinaryResourceType.image,
        folder: 'profilePics',
      );
      if (response.isSuccessful) {
        print('Get your image from with ${response.secureUrl}');

        final Map<String, String> userData = {
          'avatar': response.secureUrl ?? '',
          'userName': userName,
          'email': email,
          'password': password,
        };

        final response2 = await http.put(
          Uri.parse('$uri/users/$idUser'),
          headers: {'x-access-token': token},
          body: userData,
        );

        if (response2.statusCode == 201) {
          print('Perfil modificado con éxito.');
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('avatar', response.secureUrl ?? '');
        }
      } else {
        print('Not uploaded correctly');
      }
    } else {
      print('there is an error');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<String?> uploadImageEvents(Cloudinary cloudinary, Uint8List imageBytes, String token) async {
  try {
    if (imageBytes != null) {
      CloudinaryResponse response = await cloudinary.upload(
        fileBytes: imageBytes,
        resourceType: CloudinaryResourceType.image,
        folder: 'eventPics',
      );

      if (response.isSuccessful) {
        print('Imagen subida con éxito: ${response.secureUrl}');
        return response.secureUrl; // Devuelve la URL de la imagen
      } else {
        print('La imagen no se subió correctamente');
      }
    }
  } catch (e) {
    print('Error al subir la imagen: $e');
  }
  return null;
}
