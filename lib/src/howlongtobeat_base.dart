import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'dart:convert';
import 'models/howlongtobeat_entry.dart';

class SearchOptions {
  final int pageSize;
  final String platform;
  final String sortCategory;
  final int? minYear;
  final int? maxYear;
  final bool includeReviews;

  const SearchOptions({
    this.pageSize = 20,
    this.platform = '',
    this.sortCategory = 'popular',
    this.minYear,
    this.maxYear,
    this.includeReviews = false,
  });

  Map<String, dynamic> toJson() => {
        'searchType': 'games',
        'size': pageSize,
        'searchOptions': {
          'games': {
            'userId': 0,
            'platform': platform,
            'sortCategory': sortCategory,
            'rangeCategory': 'main',
            'rangeTime': {'min': 0, 'max': 0},
            'gameplay': {
              'perspective': '',
              'flow': '',
              'genre': '',
              'difficulty': ''
            },
            'rangeYear': {
              'min': minYear?.toString() ?? '',
              'max': maxYear?.toString() ?? '',
            },
            'modifier': '',
          },
          'users': {'sortCategory': 'postcount'},
          'lists': {'sortCategory': 'follows'},
          'filter': '',
          'sort': 0,
          'randomizer': 0
        },
        'useCache': true
      };
}

/// A Flutter package to fetch game completion times from HowLongToBeat.com

class HowLongToBeat {
  static const String _baseUrl = 'https://howlongtobeat.com/';
  static const String _searchUrl = 'api/s/';

  Future<List<HowLongToBeatEntry>> search(
    String gameName, {
    SearchOptions options = const SearchOptions(),
  }) async {
    try {
      final apiKey = await _fetchApiKey();
      final url = '$_baseUrl$_searchUrl$apiKey';

      final headers = {
        'content-type': 'application/json',
        'accept': '*/*',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'referer': _baseUrl,
      };

      final payload = {
        ...options.toJson(),
        'searchTerms': gameName.split(' '),
        'searchPage': 1,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return _parseResults(gameName, response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  Future<String> _fetchApiKey() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch homepage');
      }

      final document = parser.parse(response.body);
      final scripts = document.querySelectorAll('script[src]');

      for (var script in scripts) {
        final scriptUrl = script.attributes['src']!;
        if (scriptUrl.contains('_app-')) {
          final jsResponse = await http.get(Uri.parse('$_baseUrl$scriptUrl'));
          if (jsResponse.statusCode == 200) {
            final apiKey = _extractApiKey(jsResponse.body);
            if (apiKey != null) return apiKey;
          }
        }
      }

      throw Exception('API key not found');
    } catch (e) {
      throw Exception('Failed to fetch API key: $e');
    }
  }

  String? _extractApiKey(String scriptContent) {
    final userApiKeyPattern = RegExp(r'users\s*:\s*{\s*id\s*:\s*"([^"]+)"');
    final userMatch = userApiKeyPattern.firstMatch(scriptContent);
    if (userMatch != null) return userMatch.group(1);

    final concatPattern =
        RegExp(r'\/api\/\w+\/"(?:\.concat\(\s*"([^"]+)"\s*\))+');
    final concatMatch = concatPattern.firstMatch(scriptContent);
    if (concatMatch != null) {
      final parts = concatMatch.group(0)!.split('.concat');
      return parts
          .sublist(1)
          .map((e) => e.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''))
          .join();
    }

    return null;
  }

  List<HowLongToBeatEntry> _parseResults(String query, String jsonResponse) {
    final data = json.decode(jsonResponse)['data'] as List;
    return data.map((game) {
      final playTimes = {
        GamePlayStyle.mainStory: _convertSeconds(game['comp_main']),
        GamePlayStyle.mainExtra: _convertSeconds(game['comp_plus']),
        GamePlayStyle.completionist: _convertSeconds(game['comp_100']),
        GamePlayStyle.allStyles: _convertSeconds(game['comp_all']),
      };

      return HowLongToBeatEntry(
        gameId: int.tryParse(game['game_id'].toString()) ?? -1,
        gameName: game['game_name']?.toString() ?? 'Unknown',
        gameAlias: game['game_alias']?.toString(),
        gameType: game['game_type']?.toString(),
        gameImageUrl: game['game_image'] != null
            ? '$_baseUrl/games/${game['game_image']}'
            : null,
        gameWebLink: '$_baseUrl/game/${game['game_id']}',
        reviewScore: double.tryParse(game['review_score']?.toString() ?? '0.0'),
        profileDev: game['profile_dev']?.toString(),
        profilePlatforms: (game['profile_platform'] as String?)?.split(', '),
        releaseWorld: int.tryParse(game['release_world']?.toString() ?? '0'),
        playTimes: playTimes,
        similarity: _calculateSimilarity(
            query, game['game_name']?.toString() ?? 'Unknown'),
        jsonContent: game,
      );
    }).toList()
      ..sort((a, b) => b.similarity.compareTo(a.similarity));
  }

  double _convertSeconds(dynamic seconds) {
    if (seconds == null) return 0.0;
    if (seconds is String) return (int.tryParse(seconds) ?? 0) / 3600;
    return (seconds as int) / 3600;
  }

  double _calculateSimilarity(String a, String b) {
    final aLower = a.toLowerCase();
    final bLower = b.toLowerCase();
    final matches = aLower.runes.fold(0, (count, rune) {
      return bLower.contains(String.fromCharCode(rune)) ? count + 1 : count;
    });
    return matches / aLower.length;
  }
}
