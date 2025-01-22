import 'package:accompaneo/models/user/registration.dart';
import 'package:accompaneo/utils/helpers/snackbar_helper.dart';
import 'package:accompaneo/values/app_constants.dart';
import 'package:dio/dio.dart';

class ApiService {

  static const String baseUrl = AppConstants.urlEndpoint;

  static Future<Response> register(Registration registration) async {
    final dio = Dio();
    return await dio.post('$baseUrl/account/register', data: registration.toJson());
  }

  // static Future<Post> authenticate(int postId) async {
  //   final dio = Dio();
  //   final response = await dio.get('$baseUrl/posts/$postId');
  //   if (response.statusCode == 200) {
  //     return Post.fromJson(response.data);
  //   } else {
  //     throw Exception('Failed to fetch post: ${response.statusCode}');
  //   }
  // }
}