import 'package:flutter/material.dart';
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FavoriteMoviesScreen(favoriteMovies: []),
    );
  }
}
class FavoriteMoviesScreen extends StatefulWidget {
  final List<dynamic> favoriteMovies;

  FavoriteMoviesScreen({required this.favoriteMovies});

  @override
  _FavoriteMoviesScreenState createState() => _FavoriteMoviesScreenState();
}
class _FavoriteMoviesScreenState extends State<FavoriteMoviesScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Movies'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/moviebackground.avif"), // Use your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListView.builder(
            itemCount: widget.favoriteMovies.length,
            itemBuilder: (context, index) {
              final movie = widget.favoriteMovies[index];
              return MovieItem(
                movie: movie,
              );
            },
          ),
        ],
      ),
    );
  }
}
class MovieItem extends StatelessWidget {
  final dynamic movie;

  MovieItem({required this.movie});

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
          title: Text(movie['title'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Year: ${movie['release_date'].split('-')[0]}, IMDB: ${movie['vote_average']}',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}