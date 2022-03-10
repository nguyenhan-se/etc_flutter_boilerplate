import 'dart:io';

import 'package:dio/dio.dart';

import 'dio_connectivity_request_retrier.dart';

class TokenChangeInterceptor extends InterceptorsWrapper {
  final DioConnectivityRequestRetrier requestRetrier;

  TokenChangeInterceptor({required this.requestRetrier});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // getting token
    // var token = await sharedPrefHelper.authToken;

    // if (token != null) {
    //   options.headers.putIfAbsent('Authorization', () => token);
    // } else {
    //   print('Auth token is null');
    // }
    return handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 403 || err.response?.statusCode == 401) {
      // await refreshToken(jwt);
      requestRetrier.scheduleRequestRetry(err.requestOptions);
    }
  }

  bool _shouldRetry(DioError err) {
    return err.type == DioErrorType.connectTimeout &&
        err.error != null &&
        err.error is SocketException;
  }
}
