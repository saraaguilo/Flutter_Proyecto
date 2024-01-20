import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_flutter/image/cld_image_widget_configuration.dart';
import 'package:cloudinary_flutter/image/no_disk_cache_manager.dart';
import 'package:cloudinary_flutter/video/cld_video_controller.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';

//emulador
//String uri = 'http://192.168.56.1:9090';

//String uri = 'http://localhost:9090';
String uri = 'http://147.83.7.158:9090';

final urlCloudinary = Uri.parse(
    'CLOUDINARY_URL=cloudinary://663893452531627:0_DJghpiMZUtH4t9AX5O-967op8@dsivbpzlp');
