import 'dart:async';
import 'dart:math';

/// Types of multiplayer game modes
enum MultiplayerMode {
  realTime,       // Real-time competitive
  turnBased,      // Take turns finding words
  cooperative,    // Work together to reach target
  blitz,          // Fast-paced 1-minute rounds
}

/// Player status in multiplayer game
enum PlayerStatus {
  waiting,
  ready,
  playing,
  finished,
  disconnected,
}

/// Multiplayer player information
class MultiplayerPlayer {
  final String id;
  final String name;
  final String? avatar;
  final PlayerStatus status;
  final int score;
  final List<String> foundWords;
  final int wordsFound;
  final DateTime? lastActivity;
  final bool isHost;
  final int ping;

  const MultiplayerPlayer({
    required this.id,
    required this.name,
    this.avatar,
    required this.status,
    this.score = 0,
    this.foundWords = const [],
    this.wordsFound = 0,
    this.lastActivity,
    this.isHost = false,
    this.ping = 0,
  });

  /// Create a copy with modified values
  MultiplayerPlayer copyWith({
    String? id,
    String? name,
    String? avatar,
    PlayerStatus? status,
    int? score,
    List<String>? foundWords,
    int? wordsFound,
    DateTime? lastActivity,
    bool? isHost,
    int? ping,
  }) {
    return MultiplayerPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      score: score ?? this.score,
      foundWords: foundWords ?? this.foundWords,
      wordsFound: wordsFound ?? this.wordsFound,
      lastActivity: lastActivity ?? this.lastActivity,
      isHost: isHost ?? this.isHost,
      ping: ping ?? this.ping,
    );
  }

  /// Check if player is active
  bool get isActive {
    if (lastActivity == null) return status == PlayerStatus.playing;
    final timeSinceActivity = DateTime.now().difference(lastActivity!);
    return timeSinceActivity.inSeconds < 30 && status != PlayerStatus.disconnected;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'status': status.index,
      'score': score,
      'foundWords': foundWords,
      'wordsFound': wordsFound,
      'lastActivity': lastActivity?.toIso8601String(),
      'isHost': isHost,
      'ping': ping,
    };
  }

  /// Create from JSON
  factory MultiplayerPlayer.fromJson(Map<String, dynamic> json) {
    return MultiplayerPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      status: PlayerStatus.values[json['status'] as int],
      score: json['score'] as int? ?? 0,
      foundWords: List<String>.from(json['foundWords'] as List? ?? []),
      wordsFound: json['wordsFound'] as int? ?? 0,
      lastActivity: json['lastActivity'] != null 
          ? DateTime.parse(json['lastActivity'] as String)
          : null,
      isHost: json['isHost'] as bool? ?? false,
      ping: json['ping'] as int? ?? 0,
    );
  }
}

/// Multiplayer game room
class MultiplayerRoom {
  final String id;
  final String name;
  final MultiplayerMode mode;
  final List<MultiplayerPlayer> players;
  final int maxPlayers;
  final List<String> gameLetters;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final bool isPrivate;
  final String? password;
  final Map<String, dynamic> settings;
  final RoomStatus status;

  const MultiplayerRoom({
    required this.id,
    required this.name,
    required this.mode,
    required this.players,
    this.maxPlayers = 4,
    this.gameLetters = const [],
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.isPrivate = false,
    this.password,
    this.settings = const {},
    required this.status,
  });

  /// Create a copy with modified values
  MultiplayerRoom copyWith({
    String? id,
    String? name,
    MultiplayerMode? mode,
    List<MultiplayerPlayer>? players,
    int? maxPlayers,
    List<String>? gameLetters,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? isPrivate,
    String? password,
    Map<String, dynamic>? settings,
    RoomStatus? status,
  }) {
    return MultiplayerRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      players: players ?? this.players,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      gameLetters: gameLetters ?? this.gameLetters,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      isPrivate: isPrivate ?? this.isPrivate,
      password: password ?? this.password,
      settings: settings ?? this.settings,
      status: status ?? this.status,
    );
  }

  /// Check if room is full
  bool get isFull => players.length >= maxPlayers;

  /// Check if room can start
  bool get canStart => players.length >= 2 && players.every((p) => p.status == PlayerStatus.ready);

  /// Get host player
  MultiplayerPlayer? get host {
    final hosts = players.where((p) => p.isHost);
    return hosts.isNotEmpty ? hosts.first : null;
  }

  /// Get leaderboard sorted by score
  List<MultiplayerPlayer> get leaderboard {
    final sortedPlayers = List<MultiplayerPlayer>.from(players);
    sortedPlayers.sort((a, b) => b.score.compareTo(a.score));
    return sortedPlayers;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mode': mode.index,
      'players': players.map((p) => p.toJson()).toList(),
      'maxPlayers': maxPlayers,
      'gameLetters': gameLetters,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'isPrivate': isPrivate,
      'password': password,
      'settings': settings,
      'status': status.index,
    };
  }

  /// Create from JSON
  factory MultiplayerRoom.fromJson(Map<String, dynamic> json) {
    return MultiplayerRoom(
      id: json['id'] as String,
      name: json['name'] as String,
      mode: MultiplayerMode.values[json['mode'] as int],
      players: (json['players'] as List)
          .map((p) => MultiplayerPlayer.fromJson(p as Map<String, dynamic>))
          .toList(),
      maxPlayers: json['maxPlayers'] as int? ?? 4,
      gameLetters: List<String>.from(json['gameLetters'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt'] as String)
          : null,
      isPrivate: json['isPrivate'] as bool? ?? false,
      password: json['password'] as String?,
      settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
      status: RoomStatus.values[json['status'] as int],
    );
  }
}

/// Room status
enum RoomStatus {
  waiting,
  starting,
  playing,
  finished,
  cancelled,
}

/// Multiplayer game event
class MultiplayerEvent {
  final String type;
  final String playerId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const MultiplayerEvent({
    required this.type,
    required this.playerId,
    required this.data,
    required this.timestamp,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'playerId': playerId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MultiplayerEvent.fromJson(Map<String, dynamic> json) {
    return MultiplayerEvent(
      type: json['type'] as String,
      playerId: json['playerId'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Multiplayer game manager
class MultiplayerGameManager {
  final StreamController<MultiplayerEvent> _eventController = StreamController.broadcast();
  MultiplayerRoom? _currentRoom;
  String? _playerId;

  /// Stream of multiplayer events
  Stream<MultiplayerEvent> get events => _eventController.stream;

  /// Current room
  MultiplayerRoom? get currentRoom => _currentRoom;

  /// Current player ID
  String? get playerId => _playerId;

  /// Join a room
  Future<bool> joinRoom(String roomId, String playerName) async {
    try {
      // Simulate joining room
      _playerId = _generatePlayerId();
      
      // In real implementation, this would connect to server
      await Future.delayed(const Duration(milliseconds: 500));
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create a new room
  Future<MultiplayerRoom?> createRoom({
    required String name,
    required MultiplayerMode mode,
    int maxPlayers = 4,
    bool isPrivate = false,
    String? password,
  }) async {
    try {
      final roomId = _generateRoomId();
      final playerId = _generatePlayerId();
      _playerId = playerId;

      final host = MultiplayerPlayer(
        id: playerId,
        name: 'Host', // Would be actual player name
        status: PlayerStatus.waiting,
        isHost: true,
      );

      _currentRoom = MultiplayerRoom(
        id: roomId,
        name: name,
        mode: mode,
        players: [host],
        maxPlayers: maxPlayers,
        createdAt: DateTime.now(),
        isPrivate: isPrivate,
        password: password,
        status: RoomStatus.waiting,
      );

      return _currentRoom;
    } catch (e) {
      return null;
    }
  }

  /// Send word found event
  void sendWordFound(String word, int score) {
    final event = MultiplayerEvent(
      type: 'word_found',
      playerId: _playerId ?? '',
      data: {'word': word, 'score': score},
      timestamp: DateTime.now(),
    );
    
    _eventController.add(event);
  }

  /// Generate unique room ID
  String _generateRoomId() {
    final random = Random();
    return 'room_${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  /// Generate unique player ID
  String _generatePlayerId() {
    final random = Random();
    return 'player_${random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  /// Dispose resources
  void dispose() {
    _eventController.close();
  }
}
