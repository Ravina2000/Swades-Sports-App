import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/booking.dart';
import '../models/slot.dart';
import '../models/venue.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> _headers(String? userId) => {
        'Content-Type': 'application/json',
        'X-User-Id': ?userId,
      };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);

  Future<List<Venue>> fetchVenues() async {
    final response = await _client.get(_uri('/venues'));
    _ensureSuccess(response, fallback: 'Failed to load venues');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Venue.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<VenueSlots> fetchSlots({
    required int venueId,
    required String date,
    String? userId,
  }) async {
    final response = await _client.get(
      _uri('/venues/$venueId/slots', {'date': date}),
      headers: _headers(userId),
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
    final response = await _client.post(
      _uri('/bookings'),
      headers: _headers(userId),
      body: jsonEncode({
        'venue_id': venueId,
        'date': date,
        'start_hour': startHour,
      }),
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
    final response = await _client.get(_uri('/users/$userId/bookings'));
    _ensureSuccess(response, fallback: 'Failed to load bookings');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> cancelBooking({
    required String userId,
    required int bookingId,
  }) async {
    final response = await _client.delete(
      _uri('/bookings/$bookingId'),
      headers: _headers(userId),
    );
    _ensureSuccess(response, fallback: 'Failed to cancel booking');
  }

  void _ensureSuccess(http.Response response, {required String fallback}) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    String message = fallback;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? body['error'] as String? ?? fallback;
    } catch (_) {}

    throw ApiException(response.statusCode, message, body: response.body);
  }
}
