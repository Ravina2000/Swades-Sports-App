import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/booking.dart';
import '../models/slot.dart';
import '../models/venue.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// All requests fail fast instead of hanging forever (infinite loader).
  static const _timeout = Duration(seconds: 8);

  Map<String, String> _headers(String? userId) => {
        'Content-Type': 'application/json',
        'X-User-Id': ?userId,
      };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);

  /// Wraps every HTTP call with a timeout and converts low-level network
  /// errors into actionable messages (instead of a spinner that never ends).
  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on TimeoutException {
      throw ApiException(
        0,
        'Server not responding at ${ApiConfig.baseUrl}. '
        'Is the backend running? (cd backend && dart run bin/server.dart)',
      );
    } on SocketException catch (e) {
      throw ApiException(
        0,
        'Cannot reach ${ApiConfig.baseUrl} (${e.osError?.message ?? e.message}). '
        'Check: backend running, correct host (emulator = 10.0.2.2, '
        'physical device = your PC LAN IP via --dart-define=API_HOST=...), '
        'and firewall allows port ${ApiConfig.port}.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(0, 'Network error: ${e.message}');
    }
  }

  Future<List<Venue>> fetchVenues() async {
    final response = await _send(() => _client.get(_uri('/venues')));
    _ensureSuccess(response, fallback: 'Failed to load venues');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Venue.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<VenueSlots> fetchSlots({
    required int venueId,
    required String date,
    String? userId,
  }) async {
    final response = await _send(
      () => _client.get(
        _uri('/venues/$venueId/slots', {'date': date}),
        headers: _headers(userId),
      ),
    );
    _ensureSuccess(response, fallback: 'Failed to load slots');
    return VenueSlots.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Booking> createBooking({
    required String userId,
    required int venueId,
    required String date,
    required int startHour,
  }) async {
    final response = await _send(
      () => _client.post(
        _uri('/bookings'),
        headers: _headers(userId),
        body: jsonEncode({
          'venue_id': venueId,
          'date': date,
          'start_hour': startHour,
        }),
      ),
    );

    if (response.statusCode == 409) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException(
        409,
        body['message'] as String? ?? 'Slot already taken',
        body: response.body,
      );
    }

    _ensureSuccess(response, fallback: 'Failed to create booking');
    return Booking.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Booking>> fetchUserBookings(String userId) async {
    final response =
        await _send(() => _client.get(_uri('/users/$userId/bookings')));
    _ensureSuccess(response, fallback: 'Failed to load bookings');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cancelBooking({
    required String userId,
    required int bookingId,
  }) async {
    final response = await _send(
      () => _client.delete(
        _uri('/bookings/$bookingId'),
        headers: _headers(userId),
      ),
    );
    _ensureSuccess(response, fallback: 'Failed to cancel booking');
  }

  void _ensureSuccess(http.Response response, {required String fallback}) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String message = fallback;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message =
          body['message'] as String? ?? body['error'] as String? ?? fallback;
    } catch (_) {}

    throw ApiException(response.statusCode, message, body: response.body);
  }
}
