# HowLongToBeat Flutter Package

A Flutter package designed to fetch game completion times from [HowLongToBeat.com](howlongtobeat.com/). This package allows you to search for games, retrieve their completion times for different playstyles, and access additional game details such as release year, platforms, and review scores.

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
  howlongtobeat: ^1.0.0
```

Then, run `flutter pub get` to install the package.

## Usage

Here’s a quick example of how to use the package:

```dart
import 'package:howlongtobeat/howlongtobeat.dart';

void main() async {
  final hltb = HowLongToBeat();

  // Search for a game
  final results = await hltb.search('The Witcher 3');

  if (results.isNotEmpty) {
    final game = results.first;
    print('Game: ${game.name}');
    print('Main Story: ${game.mainStory} hours');
    print('Main + Extra: ${game.mainExtra} hours');
    print('Completionist: ${game.completionist} hours');
    print('Release Year: ${game.releaseYear}');
    print('Platforms: ${game.platforms.join(', ')}');
  }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue if you find any bugs or have suggestions for improvements.

## Acknowledgments

- [HowLongToBeat.com](howlongtobeat.com/). for providing the data.
- [ScrappyCocco](https://github.com/ScrappyCocco) for their python package.
