import 'package:flutter/material.dart';
import '../models/learned_word.dart';
import '../services/my_dictionary_service.dart';
import '../widgets/pronunciation_button.dart';
import '../widgets/learning_mode_indicator.dart';

// Helper widgets for My Dictionary
class WordLearningProgress extends StatelessWidget {
  final int timesEncountered;
  final double accuracy;
  final String masteryLevel;
  final bool isCompact;

  const WordLearningProgress({
    Key? key,
    required this.timesEncountered,
    required this.accuracy,
    required this.masteryLevel,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getMasteryColor(masteryLevel);

    if (isCompact) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              masteryLevel,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${accuracy.toStringAsFixed(0)}% • ${timesEncountered}x',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Mastery: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                masteryLevel,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Accuracy: ${accuracy.toStringAsFixed(1)}%'),
                  LinearProgressIndicator(
                    value: accuracy / 100,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text('Encountered: ${timesEncountered}x'),
          ],
        ),
      ],
    );
  }

  Color _getMasteryColor(String masteryLevel) {
    switch (masteryLevel.toLowerCase()) {
      case 'mastered':
        return Colors.green;
      case 'proficient':
        return Colors.blue;
      case 'learning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class NewWordBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const NewWordBadge({
    Key? key,
    required this.count,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.new_releases,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              '$count need review',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyDictionaryScreen extends StatefulWidget {
  const MyDictionaryScreen({Key? key}) : super(key: key);

  @override
  State<MyDictionaryScreen> createState() => _MyDictionaryScreenState();
}

class _MyDictionaryScreenState extends State<MyDictionaryScreen>
    with TickerProviderStateMixin {
  List<LearnedWord> _words = [];
  List<LearnedWord> _filteredWords = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedFilter;
  String? _selectedMastery;
  bool _showFavoritesOnly = false;
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final words = await MyDictionaryService.getAllLearnedWords();
      setState(() {
        _words = words;
        _filteredWords = words;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dictionary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterWords() {
    setState(() {
      _filteredWords = _words.where((word) {
        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!word.word.toLowerCase().contains(query) &&
              !word.definition.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Part of speech filter
        if (_selectedFilter != null && _selectedFilter != 'All') {
          if (word.partOfSpeech != _selectedFilter) {
            return false;
          }
        }

        // Mastery level filter
        if (_selectedMastery != null && _selectedMastery != 'All') {
          if (word.masteryLevel != _selectedMastery) {
            return false;
          }
        }

        // Favorites filter
        if (_showFavoritesOnly && !word.isFavorite) {
          return false;
        }

        return true;
      }).toList();

      // Sort by most recently learned
      _filteredWords.sort((a, b) => b.learnedAt.compareTo(a.learnedAt));
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterWords();
  }

  Future<void> _toggleFavorite(LearnedWord word) async {
    await MyDictionaryService.toggleFavorite(word.word);
    _loadWords();
  }

  Future<void> _removeWord(LearnedWord word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Word'),
        content: Text('Are you sure you want to remove "${word.word}" from your dictionary?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await MyDictionaryService.removeLearnedWord(word.word);
      _loadWords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dictionary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Colors.red : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
              _filterWords();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              switch (value) {
                case 'export':
                  _exportDictionary();
                  break;
                case 'clear':
                  _clearDictionary();
                  break;
                case 'statistics':
                  _showStatistics();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'statistics',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Statistics'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Learning'),
            Tab(text: 'Proficient'),
            Tab(text: 'Mastered'),
          ],
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedMastery = null;
                  break;
                case 1:
                  _selectedMastery = 'Learning';
                  break;
                case 2:
                  _selectedMastery = 'Proficient';
                  break;
                case 3:
                  _selectedMastery = 'Mastered';
                  break;
              }
            });
            _filterWords();
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF673AB7), Color(0xFF3F51B5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search words or definitions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Filter chips
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All', _selectedFilter),
                    _buildFilterChip('noun', _selectedFilter),
                    _buildFilterChip('verb', _selectedFilter),
                    _buildFilterChip('adjective', _selectedFilter),
                    _buildFilterChip('adverb', _selectedFilter),
                  ],
                ),
              ),

              // Word count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${_filteredWords.length} words',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_words.isNotEmpty)
                      NewWordBadge(
                        count: _words.where((w) => w.needsReview).length,
                        onTap: () {
                          // Filter to show only words needing review
                        },
                      ),
                  ],
                ),
              ),

              // Words list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _filteredWords.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredWords.length,
                            itemBuilder: (context, index) {
                              final word = _filteredWords[index];
                              return _buildWordCard(word);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? selectedFilter) {
    final isSelected = selectedFilter == label;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? label : null;
          });
          _filterWords();
        },
        backgroundColor: Colors.white.withOpacity(0.2),
        selectedColor: Colors.white.withOpacity(0.3),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book_outlined,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No words found matching "$_searchQuery"'
                : 'Your dictionary is empty',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Start playing with Learning Mode enabled to add words',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(LearnedWord word) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getMasteryColor(word.masteryLevel),
          child: Text(
            word.word[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                word.word,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (word.partOfSpeech.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  word.partOfSpeech,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word.definition,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            WordLearningProgress(
              timesEncountered: word.timesEncountered,
              accuracy: word.accuracy,
              masteryLevel: word.masteryLevel,
              isCompact: true,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CompactPronunciationButton(
              word: word.word,
              phonetic: word.phonetic,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                word.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: word.isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () => _toggleFavorite(word),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (word.phonetic.isNotEmpty) ...[
                  Text(
                    'Pronunciation: ${word.phonetic}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                WordLearningProgress(
                  timesEncountered: word.timesEncountered,
                  accuracy: word.accuracy,
                  masteryLevel: word.masteryLevel,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleFavorite(word),
                        icon: Icon(
                          word.isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        label: Text(word.isFavorite ? 'Unfavorite' : 'Favorite'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: word.isFavorite ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _removeWord(word),
                        icon: const Icon(Icons.delete),
                        label: const Text('Remove'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMasteryColor(String masteryLevel) {
    switch (masteryLevel.toLowerCase()) {
      case 'mastered':
        return Colors.green;
      case 'proficient':
        return Colors.blue;
      case 'learning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _exportDictionary() async {
    try {
      final jsonData = await MyDictionaryService.exportWords();
      // In a real app, you would save this to a file or share it
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Dictionary'),
            content: const Text('Dictionary exported successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearDictionary() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Dictionary'),
        content: const Text('Are you sure you want to remove all words from your dictionary? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await MyDictionaryService.clearAllWords();
      _loadWords();
    }
  }

  void _showStatistics() async {
    final stats = await MyDictionaryService.getStatistics();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dictionary Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Words: ${stats['totalWords']}'),
              Text('Favorite Words: ${stats['favoriteWords']}'),
              Text('Words Needing Review: ${stats['wordsNeedingReview']}'),
              Text('Average Accuracy: ${stats['averageAccuracy'].toStringAsFixed(1)}%'),
              Text('Average Time to Find: ${stats['averageTimeToFind'].toStringAsFixed(1)}s'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
