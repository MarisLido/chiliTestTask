import 'package:flutter/material.dart';

// Screen for displaying details of a specific gif
class GifDetailScreen extends StatelessWidget {
  // URL of the gif to be displayed
  final String gifUrl;

  const GifDetailScreen({required this.gifUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF7C8C6C),
      body: Column(
        children: [
          // Container for the app bar with back button
          Container(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            child: Row(
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                ),
              ],
            ),
          ),
          // Container for displaying the gif in the center of the screen
          Expanded(
            child: Center(
              // Hero widget for animating the transition of the gif image
              child: Hero(
                tag: gifUrl,
                child: Image.network(
                  gifUrl,
                  // fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
