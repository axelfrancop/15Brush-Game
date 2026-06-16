enum CardSuit { hearts, diamonds, clubs, spades }

enum CardRank { ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king }

class Card {
  final CardSuit suit;
  final CardRank rank;
  final String id;

  Card({
    required this.suit,
    required this.rank,
    required this.id,
  });

  String get displayName {
    return '${rank.name} of ${suit.name}';
  }

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      suit: CardSuit.values.byName(json['suit']),
      rank: CardRank.values.byName(json['rank']),
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suit': suit.name,
      'rank': rank.name,
      'id': id,
    };
  }
}
