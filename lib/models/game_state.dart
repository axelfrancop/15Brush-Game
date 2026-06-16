import 'player.dart';
import 'card.dart';

enum GameStatus { waiting, playing, finished }

class GameState {
  final String gameId;
  final List<Player> players;
  final List<Card> deck;
  final List<Card> discardPile;
  final GameStatus status;
  final String? currentPlayerTurn;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  GameState({
    required this.gameId,
    required this.players,
    required this.deck,
    required this.discardPile,
    this.status = GameStatus.waiting,
    this.currentPlayerTurn,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
  });

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      gameId: json['gameId'],
      players: (json['players'] as List)
          .map((player) => Player.fromJson(player as Map<String, dynamic>))
          .toList(),
      deck: (json['deck'] as List)
          .map((card) => Card.fromJson(card as Map<String, dynamic>))
          .toList(),
      discardPile: (json['discardPile'] as List)
          .map((card) => Card.fromJson(card as Map<String, dynamic>))
          .toList(),
      status: GameStatus.values.byName(json['status'] ?? 'waiting'),
      currentPlayerTurn: json['currentPlayerTurn'],
      createdAt: DateTime.parse(json['createdAt']),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'players': players.map((player) => player.toJson()).toList(),
      'deck': deck.map((card) => card.toJson()).toList(),
      'discardPile': discardPile.map((card) => card.toJson()).toList(),
      'status': status.name,
      'currentPlayerTurn': currentPlayerTurn,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }
}
