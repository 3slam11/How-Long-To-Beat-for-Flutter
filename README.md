# HowLongToBeat Flutter Package

A Flutter package designed to fetch game completion times from [HowLongToBeat.com](https://howlongtobeat.com/). This package allows you to search for games, retrieve their completion times for different playstyles, and access additional game details such as release year, platforms, and review scores.

The package is based on the [ScrappyCocco](https://github.com/ScrappyCocco) python package.

## Features

- **Search for Games**: Search for games by name and retrieve their completion times.
- **Playstyle Completion Times**: Get completion times for different playstyles:

  - Main Story
  - Main + Extra
  - Completionist
  - All Styles

- **Game Details**: Access additional game details such as:
  - Game ID
  - Game Name
  - Game Alias
  - Game Type
  - Game Image URL
  - Game Web Link
  - Review Score
  - Developer
  - Platforms
  - Release Year
- **Customizable Search Options**: Customize your search with options such as:
  - Page Size
  - Platform
  - Sort Category
  - Release Year Range
  - Include Reviews
- **Similarity Scoring**: Results are sorted by similarity to the search query to ensure the most relevant games are returned first.

## Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  howlongtobeat: ^latest_version
```

Then, run `flutter pub get` to install the package.

## Usage

Here’s a quick example of how to use the package:

```dart
import 'package:flutter/material.dart';
import 'package:howlongtobeat/howlongtobeat.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'How Long To Beat Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HowLongToBeatExample(),
    );
  }
}

class HowLongToBeatExample extends StatefulWidget {
  @override
  _HowLongToBeatExampleState createState() => _HowLongToBeatExampleState();
}

class _HowLongToBeatExampleState extends State<HowLongToBeatExample> {
  final hltb = HowLongToBeat();
  List<Game> _results = [];
  bool _isLoading = false;

  Future<void> _searchGame(String query) async {
    setState(() {
      _isLoading = true;
    });

    final results = await hltb.search(query);

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How Long To Beat Example'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search for a game',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (query) {
                _searchGame(query);
              },
            ),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final game = _results[index];
                      return ListTile(
                        title: Text(game.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Main Story: ${game.mainStory} hours'),
                            Text('Main + Extra: ${game.mainExtra} hours'),
                            Text('Completionist: ${game.completionist} hours'),
                            Text('Release Year: ${game.releaseYear}'),
                            Text('Platforms: ${game.platforms.join(', ')}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue if you find any bugs or have suggestions for improvements.

## Acknowledgments

- [HowLongToBeat.com](https://howlongtobeat.com/) for providing the data.
- [ScrappyCocco](https://github.com/ScrappyCocco) for their python package.
