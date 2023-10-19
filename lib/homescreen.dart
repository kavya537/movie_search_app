import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'favorites.dart';
import 'logout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> topRatedMovies = [];
  List<dynamic> displayedMovies = [];
  List<dynamic> favoriteMovies = [];

  int currentPage = 1;
  int moviesPerPage = 5;
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchTopRatedMovies(currentPage);
  }

  void fetchTopRatedMovies(int page) async {
    final apiKey = '0b0970f6de748b8fe9a4bb60c46f78d7';
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/top_rated?api_key=$apiKey&language=en-US&page=$page'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final results = data['results'];
      setState(() {
        results.forEach((movie) {
        movie['isFavorite'] = false; 
        });
        topRatedMovies.addAll(data['results']);
        displayedMovies = List.from(topRatedMovies); 
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }

  void toggleFavorite(int index) {
    setState(() {
       final movie = displayedMovies[index];
      movie['isFavorite'] = !movie['isFavorite'];

      if (movie['isFavorite']) {
        favoriteMovies.add(movie); 
      } else {
        favoriteMovies.remove(movie); 
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      currentPage++;
      fetchTopRatedMovies(currentPage);
    }
  }
  void navigateToHome() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => HomeScreen(),
    ));
  }
  void navigateToLogout() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LogoutScreen(),
    ));
  }
  void searchMovies(String query) async{
     final apiKey = '0b0970f6de748b8fe9a4bb60c46f78d7';
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=$apiKey&language=en-US&query=$query'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final results = data['results'];

      setState(() {
        results.forEach((movie) {
          movie['isFavorite'] = false; // Set isFavorite property for each movie to false
        });
        displayedMovies = results;
      });
    } else {
      throw Exception('Failed to search movies');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (topRatedMovies.isEmpty) {
      fetchTopRatedMovies(currentPage);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Rated Movies'),
        actions: [
          ElevatedButton(
            onPressed: () {
              navigateToHome();
            },
            child: Text('Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FavoriteMoviesScreen(favoriteMovies: favoriteMovies),
                ),
              );
            },
            child: Text('Favorite Movies'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogoutScreen()),
              );
            },
            child: Text('Logout'),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/moviebackground.avif"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: 'Search Movies'),
                onSubmitted: (query) {
                  searchMovies(query);
                },
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: displayedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = displayedMovies[index];
                    return MovieItem(
                      movie: movie,
                      isFavorite: movie['isFavorite'],
                      toggleFavorite: () {
                        toggleFavorite(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MovieItem extends StatelessWidget {
  final dynamic movie;
  final bool isFavorite;
  final VoidCallback? toggleFavorite;
  MovieItem({required this.movie, required this.isFavorite, required this.toggleFavorite});
  
  @override
  
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(
          'https://image.tmdb.org/t/p/original${movie['poster_path']}',
          width: 200,
          height: 200,
          fit: BoxFit.fill,
        ),
         ListTile(
          title: Text(movie['title']),
          subtitle: Text(
            'Year: ${movie['release_date'].split('-')[0]}, IMDB: ${movie['vote_average']}',
          ),
          trailing: IconButton(
            icon: isFavorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
            onPressed: toggleFavorite,
          ),
        ),
      ],
    );
  }
}
