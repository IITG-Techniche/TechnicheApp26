import 'package:flutter/material.dart';
import '../model/events_data.dart';
import 'sub_category_screen.dart';

class EventsScreen extends StatelessWidget {
  static const String routeName = '/events-screen';

  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'EVENTS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            fontFamily: 'Orbitron',
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: eventData.length,
        itemBuilder: (context, index) {
          final category = eventData[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
  builder: (_) => SubCategoryScreen(
    categoryTitle: category.title,
    subCategories: category.subCategories,
  ),
),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
