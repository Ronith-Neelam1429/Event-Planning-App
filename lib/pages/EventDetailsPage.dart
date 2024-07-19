import 'package:event_planning/components/layout/BaseLayout.dart';
import 'package:flutter/material.dart';
import 'package:event_planning/models/eventModel.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int _selectedIndex = 1; // Assuming 'Events' is the second item in the nav bar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here if needed
  }

  void _refreshEvents() {
    // Implement event refreshing logic if needed
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      refreshEvents: _refreshEvents,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.event.title),
                background: Image.network(
                  widget.event.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${widget.event.date}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Location: ${widget.event.location}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Event Type: ${widget.event.eventType}',
                          style: TextStyle(fontSize: 18),
                        ),
                        // You can add more details here if available in your Event model
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
