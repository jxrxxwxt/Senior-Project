import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import 'storage_service.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Dio get client => _dio;
}