import 'card.dart';

class GameMove {
  final Card handCard;
  final List<Card> tableCards;
  final int total;

  GameMove({
    required this.handCard,
    required this.tableCards,
    required this.total,
  });

  List<Card> get allCards => [handCard, ...tableCards];
}

class GameLogic {
  static int getCardValue(Card card) {
    switch (card.rank) {
      case CardRank.ace:
        return 1;
      case CardRank.two:
        return 2;
      case CardRank.three:
        return 3;
      case CardRank.four:
        return 4;
      case CardRank.five:
        return 5;
      case CardRank.six:
        return 6;
      case CardRank.seven:
        return 7;
      case CardRank.eight:
        return 8;
      case CardRank.nine:
        return 9;
      case CardRank.ten:
        return 10;
      default:
        return 0;
    }
  }

  static bool isValidMove(
    Card handCard,
    List<Card> selectedTableCards,
  ) {
    final total = getCardValue(handCard) +
        selectedTableCards.fold<int>(0, (sum, card) => sum + getCardValue(card));

    return total == 15;
  }

  static GameMove? findMoveIfValid(
    Card handCard,
    List<Card> selectedTableCards,
  ) {
    final total = getCardValue(handCard) +
        selectedTableCards.fold<int>(0, (sum, card) => sum + getCardValue(card));

    if (total == 15) {
      return GameMove(
        handCard: handCard,
        tableCards: selectedTableCards,
        total: total,
      );
    }
    return null;
  }

  static List<GameMove> findAllValidMoves(
    Card handCard,
    List<Card> tableCards,
  ) {
    final validMoves = <GameMove>[];
    final handValue = getCardValue(handCard);

    for (int mask = 1; mask < (1 << tableCards.length); mask++) {
      final combination = <Card>[];
      int combinationSum = 0;

      for (int i = 0; i < tableCards.length; i++) {
        if ((mask & (1 << i)) != 0) {
          combination.add(tableCards[i]);
          combinationSum += getCardValue(tableCards[i]);
        }
      }

      if (handValue + combinationSum == 15) {
        validMoves.add(GameMove(
          handCard: handCard,
          tableCards: combination,
          total: 15,
        ));
      }
    }

    return validMoves;
  }

  static int calculateScore(List<Card> cards) {
    return cards.fold<int>(0, (sum, card) => sum + getCardValue(card));
  }
}
