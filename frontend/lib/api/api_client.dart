import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Default backend base URL (the deployed Aarvy API). Overridable at runtime via
/// [SettingsStore] so a dev build can point at a local server, e.g.
/// `http://10.0.2.2:4100/api` (Android emulator alias for the host machine).
const String kDefaultBaseUrl = 'http://13.201.13.250:4100/api';

/// A paginated list envelope: `{ data, page, limit, total }`.
class Paged<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;

  const Paged({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
  });
}

/// Thin wrapper over dio: holds the (runtime-configurable) base URL + bearer
/// token, unwraps responses, and maps errors to [ApiException]. A 401 triggers
/// the [onUnauthorized] hook so the app can log out.
class ApiClient {
  late final Dio _dio;
  String _baseUrl;
  String? token;
  void Function()? onUnauthorized;

  ApiClient({String baseUrl = kDefaultBaseUrl}) : _baseUrl = baseUrl {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 401) onUnauthorized?.call();
        handler.next(e);
      },
    ));
  }

  String get baseUrl => _baseUrl;

  set baseUrl(String value) {
    _baseUrl = value;
    _dio.options.baseUrl = value;
  }

  // ---- verbs ----
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: _clean(query)));

  Future<dynamic> post(String path, {Object? body}) =>
      _send(() => _dio.post(path, data: body));

  Future<dynamic> patch(String path, {Object? body}) =>
      _send(() => _dio.patch(path, data: body));

  Future<dynamic> delete(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.delete(path, queryParameters: _clean(query)));

  Future<dynamic> _send(Future<Response> Function() run) async {
    try {
      final res = await run();
      return res.data;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  /// Fetch a paginated list and map each item via [fromJson].
  Future<Paged<T>> getPaged<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? query,
  }) async {
    final data = await get(path, query: query) as Map<String, dynamic>;
    final items = (data['data'] as List? ?? const [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
    return Paged<T>(
      data: items,
      page: (data['page'] ?? 1) as int,
      limit: (data['limit'] ?? items.length) as int,
      total: (data['total'] ?? items.length) as int,
    );
  }

  /// Fetch a `{ data: [...] }` list (no pagination envelope) and map each item.
  Future<List<T>> getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? query,
  }) async {
    final data = await get(path, query: query) as Map<String, dynamic>;
    return (data['data'] as List? ?? const [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }

  ApiException _map(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        (e.error is Exception && e.response == null)) {
      return const ApiException(
          0, 'Cannot reach the server. Check your connection.');
    }
    final status = e.response?.statusCode ?? 0;
    final body = e.response?.data;
    String message = 'Something went wrong. Please try again.';
    Object? details;
    if (body is Map) {
      message = (body['error'] ?? message).toString();
      details = body['details'];
    }
    return ApiException(status, message, details);
  }

  Map<String, dynamic>? _clean(Map<String, dynamic>? q) {
    if (q == null) return null;
    final out = <String, dynamic>{};
    q.forEach((k, v) {
      if (v != null) out[k] = v;
    });
    return out;
  }
}
