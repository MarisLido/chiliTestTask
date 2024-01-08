import 'dart:async';
import 'package:flutter/material.dart';
import 'giphy_service.dart';
import 'gif_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Service for fetching gifs
  final GiphyService giphyService =
      GiphyService('CFWJLr7j3kAyKqMXIj5wtuMkEJ6ekbx0');

  // List to store fetched gifs
  List<Gif> _gifs = [];

  // Controller for the search input field
  final _searchController = TextEditingController();

  // Timer for debouncing search input changes
  Timer? _debounceTimer;

  // Controller for the scroll view
  final _scrollController = ScrollController();

  // Flag to track if gifs are being loaded
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load initial set of gifs
    _loadGifs();

    // Listen for scroll events to trigger loading more gifs
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreGifs();
      }
    });

    // Listen for changes in the search input
    _searchController.addListener(_onSearchTextChanged);
  }

  // Method to load gifs
  void _loadGifs({int? offset}) async {
    try {
      final gifs = await giphyService.getGifs(offset: offset);
      setState(() {
        _gifs = gifs;
      });
    } catch (e) {
      print('Error loading GIFs: $e');
    }
  }

  // Method to load more gifs when reaching the end of the list
  void _loadMoreGifs() async {
    if (!_isLoading) {
      try {
        setState(() {
          _isLoading = true;
        });

        final gifs = await giphyService.getMoreGifs(offset: _gifs.length);
        setState(() {
          _gifs.addAll(gifs);
        });
      } catch (e) {
        print('Error loading more GIFs: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Method to handle search input changes with debouncing
  void _onSearchTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text;
      if (query.isEmpty) {
        // If search query is empty, load all gifs
        _loadGifs();
        // Scroll back to the top of the grid
        _scrollController.jumpTo(0.0);
      } else {
        // Perform search for gifs based on the input query
        _performSearch(query);
      }
    });
  }

  // Method to perform search for gifs
  void _performSearch(String query) async {
    try {
      final gifs = await giphyService.searchGifs(query);
      setState(() {
        _gifs = gifs;
      });
    } catch (e) {
      print('Error searching GIFs: $e');
    }
  }

  @override
  void dispose() {
    // Dispose of controllers and cancel timer to prevent memory leaks
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the number of columns based on the screen orientation
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final crossAxisCount = isPortrait ? 3 : 4;

    return Scaffold(
      backgroundColor: const Color(0XFF7C8C6C),
      body: Stack(
        children: [
          // Custom scroll view for the app bar and grid
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Custom app bar with search functionality
              appBar(),
              // Grid of gifs
              grid(crossAxisCount),
            ],
          ),
        ],
      ),
    );
  }

// Method to create a sliver app bar with search functionality
  SliverAppBar appBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 14, bottom: 16, right: 14),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(top: 13, left: 15),
              hintText: 'Search GIF\'s',
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _loadGifs();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to create a sliver grid
  SliverGrid grid(int crossAxisCount) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == _gifs.length) {
            // If the last item is reached, load more gifs
            _loadMoreGifs();
            return Container();
          } else {
            // Display individual GIFs in the grid
            Gif currentGif = _gifs[index];
            return Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  // Navigate to the detail screen when a gifs is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GifDetailScreen(gifUrl: currentGif.url),
                    ),
                  );
                },
                child: Hero(
                  tag: currentGif.url,
                  child: Image.network(
                    currentGif.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // Image is fully loaded
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                            color: const Color(0xFFB4CCB4),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          }
        },
        // Include an additional item for loading more gifs at the end
        childCount: _gifs.length + 1,
      ),
    );
  }
}
