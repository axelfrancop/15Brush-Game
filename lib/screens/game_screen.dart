import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../services/firebase_service.dart';

class GameScreen extends StatefulWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Set<int> selectedTableCards = {};
  int? selectedHandCard;

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo'),
        centerTitle: true,
      ),
      body: StreamBuilder<GameState?>(
        stream: firebaseService.watchGame(widget.gameId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Jogo não encontrado'));
          }

          final gameState = snapshot.data!;
          final currentUserId = firebaseService.getCurrentUserId();
          final currentPlayer = gameState.players
              .firstWhere((p) => p.id == currentUserId, orElse: () => throw Exception('Player not found'));

          return Column(
            children: [
              // Top: Outros jogadores
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Wrap(
                      spacing: 16,
                      children: gameState.players
                          .where((p) => p.id != currentUserId)
                          .map((player) {
                        final isCurrentTurn = player.isCurrentTurn;
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isCurrentTurn ? Colors.green : Colors.grey,
                                  width: isCurrentTurn ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    player.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cartas: ${player.hand.length}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Pontos: ${player.score}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              // Middle: Mesa
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mesa',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: gameState.tableCards.isEmpty
                            ? const Center(
                                child: Text('Aguardando cartas...'),
                              )
                            : Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: List.generate(
                                  gameState.tableCards.length,
                                  (index) {
                                    final card = gameState.tableCards[index];
                                    final isSelected = selectedTableCards.contains(index);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedTableCards.remove(index);
                                          } else {
                                            selectedTableCards.add(index);
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.blue : Colors.white,
                                          border: Border.all(
                                            color: isSelected ? Colors.blue : Colors.grey,
                                            width: isSelected ? 3 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${card.rank.name[0].toUpperCase()}${card.suit.name[0].toUpperCase()}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom: Mão do jogador
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sua Mão',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Pontos: ${currentPlayer.score}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: currentPlayer.hand.isEmpty
                            ? const Center(
                                child: Text('Sem cartas'),
                              )
                            : Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: List.generate(
                                  currentPlayer.hand.length,
                                  (index) {
                                    final card = currentPlayer.hand[index];
                                    final isSelected = selectedHandCard == index;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedHandCard = null;
                                          } else {
                                            selectedHandCard = index;
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.green
                                              : Colors.deepPurple.withOpacity(0.7),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.green
                                                : Colors.deepPurple,
                                            width: isSelected ? 3 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${card.rank.name[0].toUpperCase()}${card.suit.name[0].toUpperCase()}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: currentPlayer.isCurrentTurn
                                ? () {
                                    // TODO: Implementar fazer jogada
                                  }
                                : null,
                            icon: const Icon(Icons.check),
                            label: const Text('Fazer Jogada'),
                          ),
                          ElevatedButton.icon(
                            onPressed: currentPlayer.isCurrentTurn ? () {} : null,
                            icon: const Icon(Icons.skip_next),
                            label: const Text('Passar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
