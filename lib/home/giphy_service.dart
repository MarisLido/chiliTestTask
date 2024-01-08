import 'dart:convert';
import 'package:http/http.dart' as http;

// Class responsible for interacting with the Giphy API
class GiphyService {
  final String apiKey;
  final int pageSize = 25;

  // Constructor to initialize the GiphyService with an API key
  GiphyService(this.apiKey);

  // Fetch a list of gifs from the trending endpoint
  Future<List<Gif>> getGifs({int? offset}) async {
    final response = await http.get(
      Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=$apiKey&limit=$pageSize&offset=$offset'),
    );

    return _parseGifsResponse(response);
  }

  // Search for gifs based on a query string
  Future<List<Gif>> searchGifs(String query, {int? offset}) async {
    final response = await http.get(
      Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=$apiKey&q=$query&limit=$pageSize&offset=$offset'),
    );

    return _parseGifsResponse(response);
  }

  // Fetch additional gifs based on an offset
  Future<List<Gif>> getMoreGifs({required int offset}) async {
    final response = await http.get(
      Uri.parse(
        'https://api.giphy.com/v1/gifs/trending?api_key=$apiKey&limit=25&offset=$offset',
      ),
    );

    return _parseGifsResponse(response);
  }

  // Parse the response from the Giphy API and convert it to a list of Gif objects
  List<Gif> _parseGifsResponse(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> gifs = data['data'];

      // Mapping the raw JSON data to a list of Gif objects
      final List<Gif> parsedGifs = gifs
          .map<Gif>((gif) => Gif(
                url: gif['images']['fixed_height']['url'],
                isLoading: false,
              ))
          .toList();

      return parsedGifs;
    } else {
      // Throw an exception if the API request fails
      throw Exception('Failed to fetch GIFs');
    }
  }
}

// Class representing a Gif object with a URL and loading status
class Gif {
  final String url;
  final bool isLoading;

  // Constructor to initialize a Gif object with a URL and loading status
  Gif({
    required this.url,
    required this.isLoading,
  });
}
