import 'package:event_planning/components/EventTile.dart';
import 'package:event_planning/components/layout/BaseLayout.dart';
import 'package:event_planning/models/eventAPI.dart';
import 'package:event_planning/models/eventModel.dart';
import 'package:flutter/material.dart';
import 'package:event_planning/components/searchBar.dart';
import 'package:event_planning/models/EventCategory.dart';
import 'package:event_planning/components/NavBar.dart';
import 'package:event_planning/models/category_card.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userDetails;
  final GlobalKey<NavigatorState> navigatorKey;

  HomePage({required this.userDetails, required this.navigatorKey});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _selectedCategoryIndex = -1;
  late List<EventCategory> categories;
  List<Event> events = [];
  Set<String> likedEventIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    categories = [
      EventCategory(icon: Icons.category_outlined, name: 'All'),
      EventCategory(icon: Icons.music_note, name: 'Music'),
      EventCategory(icon: Icons.sports_tennis, name: 'Sports'),
      EventCategory(icon: Icons.theater_comedy, name: 'Theatre'),
      EventCategory(icon: Icons.emoji_emotions, name: 'Comedy'),
      EventCategory(icon: Icons.festival, name: 'Festivals'),
    ];
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      print("Fetching events...");
      final fetchedEvents = await EventService.getEvents();
      print("Fetched events: $fetchedEvents");
      setState(() {
        events = fetchedEvents;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Event> _filterEvents(String category) {
    if (category == 'All') {
      return events;
    } else {
      return events.where((event) => event.eventType == category).toList();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onCategoryTapped(int index) {
    setState(() {
      if (_selectedCategoryIndex == index) {
        _selectedCategoryIndex = -1;
        categories[index].isSelected = false;
      } else {
        if (_selectedCategoryIndex != -1) {
          categories[_selectedCategoryIndex].isSelected = false;
        }
        _selectedCategoryIndex = index;
        categories[index].isSelected = true;
      }
    });
  }

  void _toggleLike(Event event) {
    setState(() {
      if (likedEventIds.contains(event.id)) {
        likedEventIds.remove(event.id);
      } else {
        likedEventIds.add(event.id as String);
      }
    });
  }

  Widget _buildEventList() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (events.isEmpty) {
      return Center(child: Text('No events found'));
    } else {
      List<Event> filteredEvents = _selectedIndex == 1
          ? events.where((event) => likedEventIds.contains(event.id)).toList()
          : _selectedCategoryIndex == -1
              ? events
              : _filterEvents(categories[_selectedCategoryIndex].name);

      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              return EventTile(
                event: filteredEvents[index],
                isLiked: likedEventIds.contains(filteredEvents[index].id),
                onLikeToggle: _toggleLike,
              );
            },
          ),
          SizedBox(height: 120),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = widget.userDetails['displayName'] ?? 'User';
    String? profilePicUrl = widget.userDetails['profilePicture'];

    return BaseLayout(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      refreshEvents: fetchEvents,
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedIndex == 0) ...[
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 250,
                              child: Image.asset(
                                'lib/images/vector.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const Positioned(
                              top: 60,
                              right: 10,
                              child: Icon(
                                Icons.notifications_none_outlined,
                                color: Color.fromARGB(255, 0, 0, 0),
                                size: 40,
                              ),
                            ),
                            Positioned(
                              top: 60,
                              left: 20,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    child: profilePicUrl != null
                                        ? ClipOval(
                                            child: Image.network(
                                              profilePicUrl,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(Icons.person,
                                            size: 40, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Hi, $userName",
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Positioned(
                              top: 110,
                              left: 20,
                              child: Text(
                                "Find events \nnear you!",
                                style: TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0),
                              ),
                            ),
                            const Positioned(
                              bottom: -25,
                              left: 20,
                              right: 20,
                              child: CustomSearchBar(
                                hintText: 'Search...',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "Popular Events",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildCategoryList(),
                      ] else if (_selectedIndex == 1) ...[
                        SizedBox(height: 60),
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "Saved Events",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _buildEventList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FloatingNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              refreshEvents: fetchEvents,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 12),
            child: CategoryCard(
              category: categories[index],
              onTap: () => _onCategoryTapped(index),
            ),
          );
        },
      ),
    );
  }
}
