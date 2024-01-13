 import 'package:applogin/config.dart';
import 'package:http/http.dart' as http;
 import 'package:cloudinary/cloudinary.dart';
import 'package:shared_preferences/shared_preferences.dart';

 Future<void> uploadImage(cloudinary, imageBytes, userName, email, password, idUser, token) async {
    try {

      CloudinaryResponse response;

      if (imageBytes != null) {
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
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();
            await prefs.setString('avatar', response.secureUrl ?? '');
          }
        } else {
          print('Not uploaded correctly');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

