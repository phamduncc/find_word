import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for word definition from dictionary API
class WordDefinition {
  final String word;
  final String phonetic;
  final List<String> meanings;
  final String partOfSpeech;
  final List<String> examples;

  const WordDefinition({
    required this.word,
    required this.phonetic,
    required this.meanings,
    required this.partOfSpeech,
    required this.examples,
  });

  factory WordDefinition.fromJson(Map<String, dynamic> json) {
    final meanings = <String>[];
    final examples = <String>[];
    String partOfSpeech = '';

    // Parse meanings from API response
    if (json['meanings'] != null && json['meanings'] is List) {
      for (final meaning in json['meanings']) {
        if (meaning['partOfSpeech'] != null && partOfSpeech.isEmpty) {
          partOfSpeech = meaning['partOfSpeech'];
        }
        
        if (meaning['definitions'] != null && meaning['definitions'] is List) {
          for (final definition in meaning['definitions']) {
            if (definition['definition'] != null) {
              meanings.add(definition['definition']);
            }
            if (definition['example'] != null) {
              examples.add(definition['example']);
            }
          }
        }
      }
    }

    return WordDefinition(
      word: json['word'] ?? '',
      phonetic: json['phonetic'] ?? '',
      meanings: meanings,
      partOfSpeech: partOfSpeech,
      examples: examples,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'phonetic': phonetic,
      'meanings': meanings,
      'partOfSpeech': partOfSpeech,
      'examples': examples,
    };
  }

  /// Get the primary definition (first meaning)
  String get primaryDefinition => meanings.isNotEmpty ? meanings.first : '';

  /// Get the first example if available
  String get primaryExample => examples.isNotEmpty ? examples.first : '';
}

/// Service for fetching word definitions from Free Dictionary API
class DictionaryService {
  static const String _baseUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en';
  static const Duration _timeout = Duration(seconds: 10);
  
  // Cache for storing definitions to avoid repeated API calls
  static final Map<String, WordDefinition> _cache = {};

  /// Fetch word definition from Free Dictionary API
  /// Returns null if word not found or API error
  static Future<WordDefinition?> getDefinition(String word) async {
    if (word.isEmpty) return null;

    final normalizedWord = word.toLowerCase().trim();
    
    // Check cache first
    if (_cache.containsKey(normalizedWord)) {
      return _cache[normalizedWord];
    }

    try {
      final url = Uri.parse('$_baseUrl/$normalizedWord');
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final definition = WordDefinition.fromJson(data.first);
          
          // Cache the result
          _cache[normalizedWord] = definition;
          
          return definition;
        }
      } else if (response.statusCode == 404) {
        // Word not found - this is normal for some words
        return null;
      }
    } catch (e) {
      print('Dictionary API error for word "$word": $e');
      // Return offline fallback if available
      return _getOfflineFallback(normalizedWord);
    }

    return null;
  }

  /// Get offline fallback definition for common words
  static WordDefinition? _getOfflineFallback(String word) {
    final fallbacks = {
      'cat': WordDefinition(
        word: 'cat',
        phonetic: '/kæt/',
        meanings: ['A small domesticated carnivorous mammal with soft fur, a short snout, and retractable claws.'],
        partOfSpeech: 'noun',
        examples: ['The cat sat on the mat.'],
      ),
      'dog': WordDefinition(
        word: 'dog',
        phonetic: '/dɔːɡ/',
        meanings: ['A domesticated carnivorous mammal that typically has a long snout, an acute sense of smell, and a barking voice.'],
        partOfSpeech: 'noun',
        examples: ['The dog barked loudly.'],
      ),
      'house': WordDefinition(
        word: 'house',
        phonetic: '/haʊs/',
        meanings: ['A building for human habitation, especially one that consists of a ground floor and one or more upper storeys.'],
        partOfSpeech: 'noun',
        examples: ['They live in a big house.'],
      ),
      'book': WordDefinition(
        word: 'book',
        phonetic: '/bʊk/',
        meanings: ['A written or printed work consisting of pages glued or sewn together along one side and bound in covers.'],
        partOfSpeech: 'noun',
        examples: ['She read a good book.'],
      ),
      'water': WordDefinition(
        word: 'water',
        phonetic: '/ˈwɔːtər/',
        meanings: ['A colorless, transparent, odorless liquid that forms the seas, lakes, rivers, and rain.'],
        partOfSpeech: 'noun',
        examples: ['I need a glass of water.'],
      ),
      'time': WordDefinition(
        word: 'time',
        phonetic: '/taɪm/',
        meanings: ['The indefinite continued progress of existence and events in the past, present, and future.'],
        partOfSpeech: 'noun',
        examples: ['What time is it?'],
      ),
      'love': WordDefinition(
        word: 'love',
        phonetic: '/lʌv/',
        meanings: ['An intense feeling of deep affection.'],
        partOfSpeech: 'noun',
        examples: ['She felt love for her family.'],
      ),
      'life': WordDefinition(
        word: 'life',
        phonetic: '/laɪf/',
        meanings: ['The condition that distinguishes animals and plants from inorganic matter.'],
        partOfSpeech: 'noun',
        examples: ['Life is beautiful.'],
      ),
      'work': WordDefinition(
        word: 'work',
        phonetic: '/wɜːrk/',
        meanings: ['Activity involving mental or physical effort done in order to achieve a purpose or result.'],
        partOfSpeech: 'noun',
        examples: ['He goes to work every day.'],
      ),
      'play': WordDefinition(
        word: 'play',
        phonetic: '/pleɪ/',
        meanings: ['Engage in activity for enjoyment and recreation rather than a serious or practical purpose.'],
        partOfSpeech: 'verb',
        examples: ['Children love to play games.'],
      ),
    };

    return fallbacks[word];
  }

  /// Clear the definition cache
  static void clearCache() {
    _cache.clear();
  }

  /// Get cache size for debugging
  static int get cacheSize => _cache.length;

  /// Check if a word is cached
  static bool isCached(String word) {
    return _cache.containsKey(word.toLowerCase().trim());
  }
}
