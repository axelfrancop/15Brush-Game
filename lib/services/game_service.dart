import 'package:uuid/uuid.dart';
import '../models/card.dart';
import '../models/deck.dart';
import '../models/game_logic.dart';
import '../models/game_state.dart';
import '../models/player.dart';

class GameService {
  static GameState initializeGame(List<String> playerIds, List<String> playerNames) {
    const uuid = Uuid();
    final gameId = uuid.v4();
    final deck = Deck.standard();

    // Create players and deal cards
    final players = <Player>[];
    for (int i = 0; i < playerIds.length; i++) {
      final hand = deck.drawCards(3);
      players.add(Player(
        id: playerIds[i],
        name: playerNames[i],
        hand: hand,
      ));
    }

    // Deal 4 cards to the table
    final tableCards = deck.drawCards(4);

    // Set first player as current turn
    players[0] = players[0].copyWith(isCurrentTurn: true);

    return GameState(
      gameId: gameId,
      players: players,
      deck: deck.cards,
      tableCards: tableCards,
      status: GameStatus.playing,
      currentPlayerTurnId: playerIds[0],
      createdAt: DateTime.now(),
      startedAt: DateTime.now(),
    );
  }

  static GameState? makeMove(
    GameState gameState,
    String playerId,
    Card handCard,
    List<Card> selectedTableCards,
  ) {
    // Validate move
    if (!GameLogic.isValidMove(handCard, selectedTableCards)) {
      return null;
    }

    // Find player
    final playerIndex = gameState.players.indexWhere((p) => p.id == playerId);
    if (playerIndex == -1) return null;

    final player = gameState.players[playerIndex];

    // Remove card from hand
    final updatedHand = List<Card>.from(player.hand);
    updatedHand.remove(handCard);

    // Add cards to captured cards
    final updatedCaptured = List<Card>.from(player.capturedCards);
    updatedCaptured.addAll([handCard, ...selectedTableCards]);

    // Update player
    final updatedPlayer = player.copyWith(
      hand: updatedHand,
      capturedCards: updatedCaptured,
    );

    // Remove cards from table
    final updatedTableCards = List<Card>.from(gameState.tableCards);
    for (final card in selectedTableCards) {
      updatedTableCards.remove(card);
    }

    // Update players list
    final updatedPlayers = List<Player>.from(gameState.players);
    updatedPlayers[playerIndex] = updatedPlayer;

    // Get next player
    final nextPlayerIndex = (playerIndex + 1) % gameState.players.length;
    final nextPlayerId = gameState.players[nextPlayerIndex].id;

    // Update all players' turn status
    for (int i = 0; i < updatedPlayers.length; i++) {
      updatedPlayers[i] = updatedPlayers[i].copyWith(
        isCurrentTurn: i == nextPlayerIndex,
      );
    }

    // Check if table is empty and refill if there are cards in deck
    var newTableCards = updatedTableCards;
    var newDeck = gameState.deck;
    if (updatedTableCards.isEmpty && gameState.deck.isNotEmpty) {
      final cardsToAdd = gameState.deck.take(4).toList();
      newTableCards = cardsToAdd;
      newDeck = gameState.deck.skip(4).toList();
    }

    return gameState.copyWith(
      players: updatedPlayers,
      tableCards: newTableCards,
      deck: newDeck,
      currentPlayerTurnId: nextPlayerId,
    );
  }

  static GameState? passMove(GameState gameState, String playerId) {
    final playerIndex = gameState.players.indexWhere((p) => p.id == playerId);
    if (playerIndex == -1) return null;

    final nextPlayerIndex = (playerIndex + 1) % gameState.players.length;
    final nextPlayerId = gameState.players[nextPlayerIndex].id;

    // Update all players' turn status
    final updatedPlayers = List<Player>.from(gameState.players);
    for (int i = 0; i < updatedPlayers.length; i++) {
      updatedPlayers[i] = updatedPlayers[i].copyWith(
        isCurrentTurn: i == nextPlayerIndex,
      );
    }

    return gameState.copyWith(
      players: updatedPlayers,
      currentPlayerTurnId: nextPlayerId,
    );
  }

  static bool isGameOver(GameState gameState) {
    return gameState.deck.isEmpty && gameState.tableCards.isEmpty;
  }

  static GameState calculateScores(GameState gameState) {
    final updatedPlayers = gameState.players.map((player) {
      final score = GameLogic.calculateScore(player.capturedCards);
      return player.copyWith(score: score);
    }).toList();

    return gameState.copyWith(
      players: updatedPlayers,
      status: GameStatus.finished,
      finishedAt: DateTime.now(),
    );
  }
}
