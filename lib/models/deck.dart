import 'package:uuid/uuid.dart';
import 'card.dart';

class Deck {
  final List<Card> cards;

  Deck({List<Card>? cards}) : cards = cards ?? [];

  factory Deck.standard() {
    const uuid = Uuid();
    final cards = <Card>[];

    final suits = CardSuit.values;
    final ranks = [
      CardRank.ace,
      CardRank.two,
      CardRank.three,
      CardRank.four,
      CardRank.five,
      CardRank.six,
      CardRank.seven,
      CardRank.eight,
      CardRank.nine,
      CardRank.ten,
    ];

    for (final suit in suits) {
      for (final rank in ranks) {
        cards.add(Card(
          suit: suit,
          rank: rank,
          id: uuid.v4(),
        ));
      }
    }

    cards.shuffle();
    return Deck(cards: cards);
  }

  Card? drawCard() {
    if (cards.isEmpty) return null;
    return cards.removeAt(0);
  }

  List<Card> drawCards(int count) {
    final drawn = <Card>[];
    for (int i = 0; i < count && cards.isNotEmpty; i++) {
      drawn.add(drawCard()!);
    }
    return drawn;
  }

  int get remainingCards => cards.length;

  bool get isEmpty => cards.isEmpty;
}
