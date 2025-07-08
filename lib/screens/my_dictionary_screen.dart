import 'package:find_words/constants/app_constants.dart';
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
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Statistics summary
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: _buildStatsSummary(),
              ),

              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search words or definitions...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey.shade600),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filter chips
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
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
                    const SizedBox(width: 8),
                    _buildFavoriteToggle(),
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

  Widget _buildStatsSummary() {
    final totalWords = _words.length;
    final favoriteWords = _words.where((w) => w.isFavorite).length;
    final masteredWords = _words.where((w) => w.masteryLevel == 'Mastered').length;
    final needReview = _words.where((w) => w.needsReview).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Total',
            totalWords.toString(),
            Icons.library_books,
            Colors.white,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Favorites',
            favoriteWords.toString(),
            Icons.favorite,
            Colors.red.shade300,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Mastered',
            masteredWords.toString(),
            Icons.star,
            Colors.yellow.shade300,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Review',
            needReview.toString(),
            Icons.refresh,
            Colors.orange.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _showFavoritesOnly ? Colors.red.shade400 : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showFavoritesOnly ? Colors.red.shade400 : Colors.white.withOpacity(0.3),
        ),
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            _showFavoritesOnly = !_showFavoritesOnly;
          });
          _filterWords();
        },
        icon: Icon(
          Icons.favorite,
          color: _showFavoritesOnly ? Colors.white : Colors.white70,
        ),
        tooltip: _showFavoritesOnly ? 'Show all words' : 'Show favorites only',
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
        backgroundColor: Colors.white.withOpacity(0.15),
        selectedColor: Colors.white.withOpacity(0.3),
        side: BorderSide(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
        ),
        labelStyle: TextStyle(
          color: isSelected ? Color(0xFF3F51B5) : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        elevation: isSelected ? 4 : 0,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _searchQuery.isNotEmpty ? Icons.search_off : Icons.book_outlined,
                size: 64,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No words found'
                  : 'Your dictionary is empty',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No words match "$_searchQuery"\nTry a different search term'
                  : 'Start playing with Learning Mode enabled\nto discover and save new words',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Playing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(LearnedWord word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getMasteryColor(word.masteryLevel),
                _getMasteryColor(word.masteryLevel).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _getMasteryColor(word.masteryLevel).withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              word.word[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (word.isFavorite)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                const SizedBox(width: 8),
                if (word.partOfSpeech.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppConstants.mediumColor, AppConstants.hardColor],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      word.partOfSpeech,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            if (word.phonetic.isNotEmpty)
              Text(
                word.phonetic,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              word.definition,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCompactStats(word),
                ),
                CompactPronunciationButton(
                  word: word.word,
                  phonetic: word.phonetic,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Colors.grey.shade600,
          ),
          onSelected: (value) {
            switch (value) {
              case 'favorite':
                _toggleFavorite(word);
                break;
              case 'remove':
                _removeWord(word);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(
                    word.isFavorite ? Icons.favorite_border : Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(word.isFavorite ? 'Unfavorite' : 'Favorite'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Remove'),
                ],
              ),
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full definition
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.book,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Definition',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        word.definition,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      if (word.example.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.format_quote,
                              color: Colors.green.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Example',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          word.example,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Detailed progress
                _buildDetailedProgress(word),
                const SizedBox(height: 16),
                // Action buttons
                _buildActionButtons(word),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStats(LearnedWord word) {
    return Row(
      children: [
        _buildStatChip(
          icon: Icons.trending_up,
          label: '${word.accuracy.toStringAsFixed(0)}%',
          color: _getMasteryColor(word.masteryLevel),
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          icon: Icons.repeat,
          label: '${word.timesEncountered}x',
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMasteryColor(word.masteryLevel).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            word.masteryLevel,
            style: TextStyle(
              fontSize: 11,
              color: _getMasteryColor(word.masteryLevel),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedProgress(LearnedWord word) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getMasteryColor(word.masteryLevel).withOpacity(0.1),
            _getMasteryColor(word.masteryLevel).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getMasteryColor(word.masteryLevel).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: _getMasteryColor(word.masteryLevel),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Learning Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Accuracy',
                  '${word.accuracy.toStringAsFixed(1)}%',
                  word.accuracy / 100,
                  _getMasteryColor(word.masteryLevel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressItem(
                  'Mastery',
                  word.masteryLevel,
                  _getMasteryProgress(word.masteryLevel),
                  _getMasteryColor(word.masteryLevel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Times Seen',
                  '${word.timesEncountered}',
                  Icons.visibility,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Avg. Time',
                  '${word.averageTimeToFind.toStringAsFixed(1)}s',
                  Icons.timer,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Learned',
                  _formatDate(word.learnedAt),
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(LearnedWord word) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _toggleFavorite(word),
            icon: Icon(
              word.isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 18,
            ),
            label: Text(word.isFavorite ? 'Unfavorite' : 'Add to Favorites'),
            style: ElevatedButton.styleFrom(
              backgroundColor: word.isFavorite ? AppConstants.errorColor : AppConstants.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _removeWord(word),
          icon: const Icon(Icons.delete, size: 18),
          label: const Text('Remove'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.errorColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  double _getMasteryProgress(String masteryLevel) {
    switch (masteryLevel.toLowerCase()) {
      case 'mastered':
        return 1.0;
      case 'proficient':
        return 0.75;
      case 'learning':
        return 0.5;
      default:
        return 0.25;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '${difference}d ago';
    if (difference < 30) return '${(difference / 7).round()}w ago';
    return '${(difference / 30).round()}m ago';
  }

  Color _getMasteryColor(String masteryLevel) {
    switch (masteryLevel.toLowerCase()) {
      case 'mastered':
        return Colors.green.shade600;
      case 'proficient':
        return Colors.blue.shade600;
      case 'learning':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
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
