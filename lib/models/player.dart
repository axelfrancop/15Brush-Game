import 'card.dart';

class Player {
  final String id;
  final String name;
  final List<Card> hand;
  final List<Card> capturedCards;
  int score;
  bool isCurrentTurn;

  Player({
    required this.id,
    required this.name,
    required this.hand,
    List<Card>? capturedCards,
    this.score = 0,
    this.isCurrentTurn = false,
  }) : capturedCards = capturedCards ?? [];

  Player copyWith({
    String? id,
    String? name,
    List<Card>? hand,
    List<Card>? capturedCards,
    int? score,
    bool? isCurrentTurn,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      hand: hand ?? this.hand,
      capturedCards: capturedCards ?? this.capturedCards,
      score: score ?? this.score,
      isCurrentTurn: isCurrentTurn ?? this.isCurrentTurn,
    );
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      hand: (json['hand'] as List?)
          ?.map((card) => Card.fromJson(card as Map<String, dynamic>))
          .toList() ?? [],
      capturedCards: (json['capturedCards'] as List?)
          ?.map((card) => Card.fromJson(card as Map<String, dynamic>))
          .toList() ?? [],
      score: json['score'] ?? 0,
      isCurrentTurn: json['isCurrentTurn'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hand': hand.map((card) => card.toJson()).toList(),
      'capturedCards': capturedCards.map((card) => card.toJson()).toList(),
      'score': score,
      'isCurrentTurn': isCurrentTurn,
    };
  }
}
