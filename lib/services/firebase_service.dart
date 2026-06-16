import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_state.dart';
import '../models/player.dart';

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

      final gameState = GameState(
        gameId: gameId,
        players: [
          Player(
            id: userId,
            name: playerName,
            hand: [],
          ),
        ],
        deck: [],
        discardPile: [],
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

  Future<void> updateGameState(String gameId, GameState gameState) async {
    try {
      await _firestore.collection('games').doc(gameId).update(gameState.toJson());
    } catch (e) {
      print('Error updating game state: $e');
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

  Future<void> deleteGame(String gameId) async {
    try {
      await _firestore.collection('games').doc(gameId).delete();
    } catch (e) {
      print('Error deleting game: $e');
      rethrow;
    }
  }
}
