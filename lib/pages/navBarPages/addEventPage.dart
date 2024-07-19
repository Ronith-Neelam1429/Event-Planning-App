import 'package:flutter/material.dart';
import 'package:event_planning/models/eventModel.dart';
import 'package:event_planning/models/eventAPI.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  DateTime? selectedDate;
  String location = '';
  String imageUrl = '';
  String eventType = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      _formKey.currentState!.save();

      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

      Event newEvent = Event(
        id: 0, // The database will assign the actual ID
        title: title,
        date: formattedDate,
        location: location,
        imageUrl: imageUrl,
        eventType: eventType,
      );

      try {
        await EventService.createEvent(newEvent);
        print("Event created successfully: $newEvent"); // Add this line
        Navigator.pop(context, true);
      } catch (e) {
        print('Error creating event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create event. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null,
              onSaved: (value) => title = value!,
            ),
            ListTile(
              title: Text(selectedDate == null
                  ? 'No date chosen'
                  : 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Location'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a location' : null,
              onSaved: (value) => location = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Image URL'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter an image URL' : null,
              onSaved: (value) => imageUrl = value!,
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}
