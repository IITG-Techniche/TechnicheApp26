import 'package:amazon_clone/utils/animate_gradient_background.dart';
import 'package:flutter/material.dart';
import '../model/events_data.dart';
import 'sub_category_screen.dart';
import 'package:flutter/services.dart';

class EventsScreen extends StatelessWidget {
  static const String routeName = '/events-screen';

  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.transparent,
  extendBodyBehindAppBar: true,  // <-- enable body behind appbar
  appBar: AppBar(
    title: const Text('EVENTS'),
    centerTitle: true,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
  body: Stack(
    children: [
      const AnimatedGradientBackground(), // background fills entire screen, behind appbar

      ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight, // <-- padding top for appbar
          left: 20,
          right: 20,
          bottom: 20,
        ),
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
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.title.toUpperCase(),
                    style: const TextStyle(
                      // color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      // fontFamily: 'Orbitron',
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
    ],
  ),
);
  }
}