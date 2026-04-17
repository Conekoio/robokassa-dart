import 'package:dio/dio.dart';
import 'package:robokassa_dart/src/exceptions.dart';

class RobokassaHttpResponse {
  final String body;
  final int statusCode;

  const RobokassaHttpResponse({required this.body, required this.statusCode});
}

abstract class RobokassaHttpClient {
  Future<RobokassaHttpResponse> get(
    String url, {
    Map<String, String>? headers,
  });

  Future<RobokassaHttpResponse> post(
    String url, {
    required Object body,
    Map<String, String>? headers,
  });
}

class DioRobokassaHttpClient implements RobokassaHttpClient {
  final Dio _dio;

  DioRobokassaHttpClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                responseType: ResponseType.plain,
                validateStatus: (_) => true,
              ),
            );

  @override
  Future<RobokassaHttpResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.getUri<String>(
        Uri.parse(url),
        options: Options(
          headers: headers,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      return RobokassaHttpResponse(
        body: response.data ?? '',
        statusCode: response.statusCode ?? 0,
      );
    } on DioException catch (e) {
      throw RobokassaException('HTTP GET failed: ${e.message}', e);
    }
  }

  @override
  Future<RobokassaHttpResponse> post(
    String url, {
    required Object body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.postUri<String>(
        Uri.parse(url),
        data: body,
        options: Options(
          headers: headers,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
        ),
      );
      return RobokassaHttpResponse(
        body: response.data ?? '',
        statusCode: response.statusCode ?? 0,
      );
    } on DioException catch (e) {
      throw RobokassaException('HTTP POST failed: ${e.message}', e);
    }
  }
}
