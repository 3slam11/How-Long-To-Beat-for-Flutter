import 'package:flutter/foundation.dart';

enum GamePlayStyle {
  mainStory,
  mainExtra,
  completionist,
  allStyles,
}

@immutable
class HowLongToBeatEntry {
  final int gameId;
  final String gameName;
  final String? gameAlias;
  final String? gameType;
  final String? gameImageUrl;
  final String? gameWebLink;
  final double? reviewScore;
  final String? profileDev;
  final List<String>? profilePlatforms;
  final int? releaseWorld;
  final double similarity;
  final Map<GamePlayStyle, double?> playTimes;
  final Map<String, dynamic>? jsonContent;

  const HowLongToBeatEntry({
    required this.gameId,
    required this.gameName,
    this.gameAlias,
    this.gameType,
    this.gameImageUrl,
    this.gameWebLink,
    this.reviewScore,
    this.profileDev,
    this.profilePlatforms,
    this.releaseWorld,
    this.similarity = -1,
    required this.playTimes,
    this.jsonContent,
  });

  double? get mainStory => playTimes[GamePlayStyle.mainStory];
  double? get mainExtra => playTimes[GamePlayStyle.mainExtra];
  double? get completionist => playTimes[GamePlayStyle.completionist];
  double? get allStyles => playTimes[GamePlayStyle.allStyles];

  bool get hasPlayTimeData =>
      playTimes.values.any((time) => time != null && time > 0);

  String get formattedPlayTime {
    final List<String> times = [];

    if (mainStory != null && mainStory! > 0) {
      times.add('Main Story: ${mainStory!.toStringAsFixed(1)} hours');
    }
    if (mainExtra != null && mainExtra! > 0) {
      times.add('Main + Extra: ${mainExtra!.toStringAsFixed(1)} hours');
    }
    if (completionist != null && completionist! > 0) {
      times.add('Completionist: ${completionist!.toStringAsFixed(1)} hours');
    }

    return times.isEmpty ? 'No playtime data available' : times.join('\n');
  }

  String get formattedPlatforms {
    return profilePlatforms?.join(', ') ?? 'Platforms unknown';
  }

  String get formattedReleaseYear {
    return releaseWorld != null && releaseWorld! > 0
        ? 'Released: $releaseWorld'
        : 'Release year unknown';
  }

  @override
  String toString() {
    return '''
$gameName
${formattedPlayTime}
${formattedPlatforms}
${formattedReleaseYear}''';
  }

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'gameName': gameName,
        'gameAlias': gameAlias,
        'gameType': gameType,
        'gameImageUrl': gameImageUrl,
        'gameWebLink': gameWebLink,
        'reviewScore': reviewScore,
        'profileDev': profileDev,
        'profilePlatforms': profilePlatforms,
        'releaseWorld': releaseWorld,
        'similarity': similarity,
        'playTimes':
            playTimes.map((key, value) => MapEntry(key.toString(), value)),
      };

  factory HowLongToBeatEntry.fromJson(Map<String, dynamic> json) {
    return HowLongToBeatEntry(
      gameId: json['gameId'] as int,
      gameName: json['gameName'] as String,
      gameAlias: json['gameAlias'] as String?,
      gameType: json['gameType'] as String?,
      gameImageUrl: json['gameImageUrl'] as String?,
      gameWebLink: json['gameWebLink'] as String?,
      reviewScore: json['reviewScore'] as double?,
      profileDev: json['profileDev'] as String?,
      profilePlatforms: (json['profilePlatforms'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      releaseWorld: json['releaseWorld'] as int?,
      similarity: json['similarity'] as double? ?? -1,
      playTimes: (json['playTimes'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                  GamePlayStyle.values.firstWhere((e) => e.toString() == key),
                  value as double?)) ??
          {},
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HowLongToBeatEntry &&
          runtimeType == other.runtimeType &&
          gameId == other.gameId &&
          gameName == other.gameName;

  @override
  int get hashCode => gameId.hashCode ^ gameName.hashCode;
}
