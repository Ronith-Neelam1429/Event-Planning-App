import 'dart:convert';
import 'package:event_planning/models/eventModel.dart';
import 'package:http/http.dart' as http;

class EventService {
  static const String baseUrl = 'http://-ip-addres:3000';

  static Future<List<Event>> getEvents() async {
    try {
      print("Fetching events from $baseUrl/events");
      final response = await http.get(Uri.parse('$baseUrl/events'));
      print("API Response status code: ${response.statusCode}");
      print("API Response body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonEvents = json.decode(response.body);
        return jsonEvents.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load events. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in getEvents: $e");
      throw e;
    }
  }

  static Future<Event> createEvent(Event event) async {
    try {
      print("Creating event: ${event.title}");
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': event.title,
          'date': event.date,
          'location': event.location,
          'image_url': event.imageUrl,
        }),
      );
      print("API Response status code: ${response.statusCode}");
      print("API Response body: ${response.body}");

      if (response.statusCode == 201) {
        return Event.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to create event. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in createEvent: $e");
      throw e;
    }
  }
}
