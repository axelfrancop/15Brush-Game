import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import 'game_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Auth Methods
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Game Methods
  Future<String> createGame(String playerName) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      final gameRef = _firestore.collection('games').doc();
      final gameId = gameRef.id;

      final player = Player(
        id: userId,
        name: playerName,
        hand: [],
      );

      final gameState = GameState(
        gameId: gameId,
        players: [player],
        deck: [],
        status: GameStatus.waiting,
        createdAt: DateTime.now(),
      );

      await gameRef.set(gameState.toJson());
      return gameId;
    } catch (e) {
      print('Error creating game: $e');
      rethrow;
    }
  }

  Future<void> joinGame(String gameId, String playerName) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      final gameRef = _firestore.collection('games').doc(gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameState = GameState.fromJson(gameDoc.data() as Map<String, dynamic>);

      // Check if player already in game
      final playerExists = gameState.players.any((p) => p.id == userId);
      if (playerExists) return;

      // Add new player
      final newPlayer = Player(id: userId, name: playerName, hand: []);
      gameState.players.add(newPlayer);

      await gameRef.update({
        'players': gameState.players.map((p) => p.toJson()).toList(),
      });
    } catch (e) {
      print('Error joining game: $e');
      rethrow;
    }
  }

  Future<void> startGame(String gameId) async {
    try {
      final gameRef = _firestore.collection('games').doc(gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameState = GameState.fromJson(gameDoc.data() as Map<String, dynamic>);

      if (gameState.players.length < 2) {
        throw Exception('Need at least 2 players to start');
      }

      // Initialize game
      final playerIds = gameState.players.map((p) => p.id).toList();
      final playerNames = gameState.players.map((p) => p.name).toList();

      final initializedGame = GameService.initializeGame(playerIds, playerNames);

      await gameRef.update(initializedGame.toJson());
    } catch (e) {
      print('Error starting game: $e');
      rethrow;
    }
  }

  Stream<GameState?> watchGame(String gameId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return GameState.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  Future<void> makeMove(
    String gameId,
    String playerId,
    String handCardId,
    List<String> selectedTableCardIds,
  ) async {
    try {
      final gameRef = _firestore.collection('games').doc(gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameState = GameState.fromJson(gameDoc.data() as Map<String, dynamic>);

      // Find the player and their hand card
      final player = gameState.players.firstWhere((p) => p.id == playerId);
      final handCard = player.hand.firstWhere((c) => c.id == handCardId);

      // Find selected table cards
      final selectedTableCards = gameState.tableCards
          .where((c) => selectedTableCardIds.contains(c.id))
          .toList();

      // Make the move
      final updatedGameState = GameService.makeMove(
        gameState,
        playerId,
        handCard,
        selectedTableCards,
      );

      if (updatedGameState == null) {
        throw Exception('Invalid move');
      }

      // Check if game is over
      if (GameService.isGameOver(updatedGameState)) {
        final finalGameState = GameService.calculateScores(updatedGameState);
        await gameRef.update(finalGameState.toJson());
      } else {
        await gameRef.update(updatedGameState.toJson());
      }
    } catch (e) {
      print('Error making move: $e');
      rethrow;
    }
  }

  Future<void> passMove(String gameId, String playerId) async {
    try {
      final gameRef = _firestore.collection('games').doc(gameId);
      final gameDoc = await gameRef.get();

      if (!gameDoc.exists) throw Exception('Game not found');

      final gameState = GameState.fromJson(gameDoc.data() as Map<String, dynamic>);
      final updatedGameState = GameService.passMove(gameState, playerId);

      if (updatedGameState == null) {
        throw Exception('Invalid pass');
      }

      await gameRef.update(updatedGameState.toJson());
    } catch (e) {
      print('Error passing move: $e');
      rethrow;
    }
  }

  Future<void> deleteGame(String gameId) async {
    try {
      await _firestore.collection('games').doc(gameId).delete();
    } catch (e) {
      print('Error deleting game: $e');
      rethrow;
    }
  }
}
