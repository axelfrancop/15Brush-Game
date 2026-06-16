import 'player.dart';
import 'card.dart';

enum GameStatus { waiting, playing, finished }

class GameState {
  final String gameId;
  final List<Player> players;
  final List<Card> deck;
  final List<Card> tableCards;
  final GameStatus status;
  final String? currentPlayerTurnId;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  GameState({
    required this.gameId,
    required this.players,
    required this.deck,
    List<Card>? tableCards,
    this.status = GameStatus.waiting,
    this.currentPlayerTurnId,
    required this.createdAt,
    this.startedAt,
    this.finishedAt,
  }) : tableCards = tableCards ?? [];

  GameState copyWith({
    String? gameId,
    List<Player>? players,
    List<Card>? deck,
    List<Card>? tableCards,
    GameStatus? status,
    String? currentPlayerTurnId,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return GameState(
      gameId: gameId ?? this.gameId,
      players: players ?? this.players,
      deck: deck ?? this.deck,
      tableCards: tableCards ?? this.tableCards,
      status: status ?? this.status,
      currentPlayerTurnId: currentPlayerTurnId ?? this.currentPlayerTurnId,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  Player? getCurrentPlayer() {
    if (currentPlayerTurnId == null) return null;
    return players.firstWhere(
      (p) => p.id == currentPlayerTurnId,
      orElse: () => throw Exception('Current player not found'),
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      gameId: json['gameId'],
      players: (json['players'] as List?)
          ?.map((player) => Player.fromJson(player as Map<String, dynamic>))
          .toList() ?? [],
      deck: (json['deck'] as List?)
          ?.map((card) => Card.fromJson(card as Map<String, dynamic>))
          .toList() ?? [],
      tableCards: (json['tableCards'] as List?)
          ?.map((card) => Card.fromJson(card as Map<String, dynamic>))
          .toList() ?? [],
      status: GameStatus.values.byName(json['status'] ?? 'waiting'),
      currentPlayerTurnId: json['currentPlayerTurnId'],
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
      'tableCards': tableCards.map((card) => card.toJson()).toList(),
      'status': status.name,
      'currentPlayerTurnId': currentPlayerTurnId,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }
}
