import 'package:flutter/material.dart';
import 'package:howlongtobeat/howlongtobeat.dart';

// Example 1: Basic game search

class GameSearchScreen extends StatefulWidget {
  const GameSearchScreen({super.key});

  @override
  State<GameSearchScreen> createState() => _GameSearchScreenState();
}

class _GameSearchScreenState extends State<GameSearchScreen> {
  final HowLongToBeat _hltb = HowLongToBeat();
  final TextEditingController _controller = TextEditingController();
  List<HowLongToBeatEntry> _results = [];
  bool _isLoading = false;

  Future<void> _searchGames() async {
    setState(() => _isLoading = true);
    try {
      final results = await _hltb.search(_controller.text);
      if (!mounted) return;
      setState(() => _results = results);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (!mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Time Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Game Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchGames,
                ),
              ),
              onSubmitted: (_) => _searchGames(),
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final entry = _results[index];
                  return ListTile(
                    title: Text(entry.gameName),
                    subtitle: Text(entry.formattedPlayTime),
                    leading: entry.gameImageUrl != null
                        ? Image.network(entry.gameImageUrl!)
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameDetailScreen(entry: entry),
                      ),
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

// Example 2: Game detail screen

class GameDetailScreen extends StatelessWidget {
  final HowLongToBeatEntry entry;

  const GameDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.gameName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.gameImageUrl != null)
              Center(
                child: Image.network(
                  entry.gameImageUrl!,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 16),
            _buildInfoCard('Play Times', entry.formattedPlayTime),
            _buildInfoCard('Platforms', entry.formattedPlatforms),
            _buildInfoCard('Release Year', entry.formattedReleaseYear),
            if (entry.reviewScore != null)
              _buildInfoCard(
                'Review Score',
                '⭐ ${entry.reviewScore!.toStringAsFixed(1)}/10',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}

// Example 3: Search Results List

class SearchResultsList extends StatelessWidget {
  final List<HowLongToBeatEntry> results;

  const SearchResultsList({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final entry = results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 60),
            child: entry.gameImageUrl != null
                ? Image.network(entry.gameImageUrl!)
                : const Icon(Icons.videogame_asset),
          ),
          title: Text(
            entry.gameName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.mainStory != null)
                Text('Main Story: ${entry.mainStory!.toStringAsFixed(1)}h'),
              if (entry.mainExtra != null)
                Text('Main + Extra: ${entry.mainExtra!.toStringAsFixed(1)}h'),
              const SizedBox(height: 4),
              Text(
                entry.formattedPlatforms,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showGameDetails(context, entry),
        );
      },
    );
  }

  void _showGameDetails(BuildContext context, HowLongToBeatEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => GameDetailScreen(entry: entry),
      isScrollControlled: true,
    );
  }
}
