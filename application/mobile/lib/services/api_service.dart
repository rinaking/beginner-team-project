import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/detection.dart';
import '../models/drug.dart';
import '../models/medication.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : client = client ?? http.Client(),
        baseUrl = _normalize(baseUrl ?? AppConfig.apiBaseUrl);

  final http.Client client;
  final String baseUrl;

  static String _normalize(String value) {
    var text = value.trim();
    while (text.endsWith('/')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }

  Future<int> supportedDrugCount() async {
    final body = await _getObject('/meta');
    return (body['supported_drug_count'] as num?)?.toInt() ?? 0;
  }

  Future<List<DrugDetail>> searchDrugs(String query) async {
    final body = await _getObject('/drugs/search', query: {'q': query});
    final results = body['results'];
    if (results is! List) return const [];
    return results.whereType<Map<String, dynamic>>().map((item) {
      return DrugDetail(
        kCode: item['k_code'] as String,
        drug: DrugInfo.fromJson(item['drug'] as Map<String, dynamic>),
        basics: const DrugBasics(),
        official: const OfficialProfile(),
      );
    }).toList();
  }

  Future<DrugDetail> drugDetail(String kCode) async {
    final body = await _getObject('/drugs/$kCode');
    return DrugDetail.fromJson(body);
  }

  Future<PredictResult> predict(List<int> bytes, String filename) async {
    final request = http.MultipartRequest('POST', _uri('/predict'));
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename.isEmpty ? 'pill.jpg' : filename,
      ),
    );
    final response = await _guard(
      () async => http.Response.fromStream(await client.send(request)),
      timeout: const Duration(seconds: 90),
    );
    return PredictResult.fromJson(_object(response));
  }

  Future<InteractionResult> checkInteractions({
    required String kCode,
    required List<String> compareKCodes,
  }) async {
    final body = await _sendObject(
      'POST',
      '/interactions/check',
      {'k_code': kCode, 'compare_k_codes': compareKCodes},
    );
    return InteractionResult.fromJson(body);
  }

  Future<List<Medication>> medications() async {
    final response = await _guard(() => client.get(_uri('/medications')));
    return _list(response).whereType<Map<String, dynamic>>().map(Medication.fromJson).toList();
  }

  Future<Medication> createMedication({
    required String kCode,
    required String startDate,
    required String? endDate,
    required List<String> times,
    required String? memo,
  }) async {
    final body = await _sendObject('POST', '/medications', {
      'k_code': kCode,
      'start_date': startDate,
      'end_date': endDate,
      'times': times,
      'memo': memo,
    });
    return Medication.fromJson(body);
  }

  Future<Medication> updateMedication({
    required int id,
    required String kCode,
    required String startDate,
    required String? endDate,
    required List<String> times,
    required String? memo,
  }) async {
    final body = await _sendObject('PUT', '/medications/$id', {
      'k_code': kCode,
      'start_date': startDate,
      'end_date': endDate,
      'times': times,
      'memo': memo,
    });
    return Medication.fromJson(body);
  }

  Future<void> deleteMedication(int id) async {
    final response = await _guard(() => client.delete(_uri('/medications/$id')));
    _ensureOk(response);
  }

  Future<ScheduleDay> today() async {
    return ScheduleDay.fromJson(await _getObject('/schedules/today'));
  }

  Future<ScheduleDay> history(String date) async {
    return ScheduleDay.fromJson(
      await _getObject('/history', query: {'date': date}),
    );
  }

  Future<Dose> markTaken({
    required int medicationId,
    required String date,
    required String scheduledTime,
  }) async {
    final body = await _sendObject('POST', '/schedules/taken', {
      'medication_id': medicationId,
      'date': date,
      'scheduled_time': scheduledTime,
    });
    return Dose.fromJson(body);
  }

  Future<Dose> cancelTaken({
    required int medicationId,
    required String date,
    required String scheduledTime,
  }) async {
    final body = await _sendObject('POST', '/schedules/cancel', {
      'medication_id': medicationId,
      'date': date,
      'scheduled_time': scheduledTime,
    });
    return Dose.fromJson(body);
  }

  Future<Map<String, dynamic>> _getObject(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _guard(() => client.get(_uri(path, query)));
    return _object(response);
  }

  Future<Map<String, dynamic>> _sendObject(
    String method,
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await _guard(() {
      final uri = _uri(path);
      final body = jsonEncode(payload);
      final headers = {'Content-Type': 'application/json; charset=utf-8'};
      switch (method) {
        case 'POST':
          return client.post(uri, headers: headers, body: body);
        case 'PUT':
          return client.put(uri, headers: headers, body: body);
        default:
          return client.post(uri, headers: headers, body: body);
      }
    });
    return _object(response);
  }

  Future<http.Response> _guard(
    Future<http.Response> Function() send, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      return await send().timeout(timeout);
    } on TimeoutException {
      throw ApiException('서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해 주세요.');
    } on SocketException {
      throw ApiException('서버에 연결할 수 없습니다. 백엔드 실행 상태와 API 주소를 확인해 주세요.');
    } on http.ClientException {
      throw ApiException('서버에 연결할 수 없습니다. 백엔드 실행 상태와 API 주소를 확인해 주세요.');
    }
  }

  Map<String, dynamic> _object(http.Response response) {
    _ensureOk(response);
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException('서버 응답을 해석하지 못했습니다.');
  }

  List<dynamic> _list(http.Response response) {
    _ensureOk(response);
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is List) return decoded;
    throw ApiException('서버 응답을 해석하지 못했습니다.');
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw ApiException(_message(response));
  }

  String _message(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && decoded['detail'] is String) {
        return decoded['detail'] as String;
      }
    } catch (_) {}
    return '요청을 처리하지 못했습니다.';
  }
}
