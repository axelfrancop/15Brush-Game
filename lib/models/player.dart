import 'card.dart';

class Player {
  final String id;
  final String name;
  final List<Card> hand;
  int score;
  bool isCurrentTurn;

  Player({
    required this.id,
    required this.name,
    required this.hand,
    this.score = 0,
    this.isCurrentTurn = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      hand: (json['hand'] as List)
          .map((card) => Card.fromJson(card as Map<String, dynamic>))
          .toList(),
      score: json['score'] ?? 0,
      isCurrentTurn: json['isCurrentTurn'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hand': hand.map((card) => card.toJson()).toList(),
      'score': score,
      'isCurrentTurn': isCurrentTurn,
    };
  }
}
