import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_logic.dart';
import '../models/game_state.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';

class GameScreen extends StatefulWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Set<int> selectedTableCards = {};
  int? selectedHandCard;
  bool _isProcessing = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _makeMove(GameState gameState) async {
    if (selectedHandCard == null) {
      _showError('Selecione uma carta da mão');
      return;
    }

    final currentUserId = context.read<FirebaseService>().getCurrentUserId();
    final currentPlayer = gameState.players
        .firstWhere((p) => p.id == currentUserId, orElse: () => throw Exception('Player not found'));

    final handCard = currentPlayer.hand[selectedHandCard!];
    final selectedCards = selectedTableCards
        .map((index) => gameState.tableCards[index])
        .toList();

    // Validate move
    if (!GameLogic.isValidMove(handCard, selectedCards)) {
      _showError('A soma não é igual a 15!');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final firebaseService = context.read<FirebaseService>();
      final selectedCardIds = selectedCards.map((c) => c.id).toList();

      await firebaseService.makeMove(
        widget.gameId,
        currentUserId!,
        handCard.id,
        selectedCardIds,
      );

      if (mounted) {
        _showSuccess('Jogada realizada!');
        setState(() {
          selectedTableCards.clear();
          selectedHandCard = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _passMove(GameState gameState) async {
    final currentUserId = context.read<FirebaseService>().getCurrentUserId();

    setState(() => _isProcessing = true);

    try {
      final firebaseService = context.read<FirebaseService>();
      await firebaseService.passMove(widget.gameId, currentUserId!);

      if (mounted) {
        _showSuccess('Você passou sua vez');
        setState(() {
          selectedTableCards.clear();
          selectedHandCard = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();

    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Sair do jogo?'),
                content: const Text('Você perderá a partida atual'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sair'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jogo'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
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

            // Game over check
            if (gameState.status == GameStatus.finished) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    final winner = gameState.players.reduce((a, b) => a.score > b.score ? a : b);
                    return AlertDialog(
                      title: const Text('Jogo Terminado!'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Vencedor: ${winner.name}'),
                          const SizedBox(height: 16),
                          ...gameState.players.map((p) => Text('${p.name}: ${p.score} pontos')).toList(),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          },
                          child: const Text('Voltar'),
                        ),
                      ],
                    );
                  },
                );
              });
            }

            final sum = currentPlayer.hand.isEmpty
                ? 0
                : GameLogic.getCardValue(currentPlayer.hand[selectedHandCard ?? 0]);
            final tableSum = selectedTableCards.isEmpty
                ? 0
                : selectedTableCards.fold<int>(
                    0,
                    (total, idx) => total + GameLogic.getCardValue(gameState.tableCards[idx]),
                  );
            final totalSum = (selectedHandCard != null ? GameLogic.getCardValue(currentPlayer.hand[selectedHandCard!]) : 0) +
                selectedTableCards.fold<int>(0, (total, idx) => total + GameLogic.getCardValue(gameState.tableCards[idx]));

            return Column(
              children: [
                // Top: Placar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: gameState.players.map((player) {
                      final isCurrentTurn = player.isCurrentTurn;
                      return Column(
                        children: [
                          Text(
                            player.name,
                            style: TextStyle(
                              fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
                              fontSize: isCurrentTurn ? 16 : 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${player.score} pontos',
                            style: TextStyle(
                              color: isCurrentTurn ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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
                                  child: Text('Sem cartas na mesa'),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    gameState.tableCards.length,
                                    (index) {
                                      final card = gameState.tableCards[index];
                                      final isSelected = selectedTableCards.contains(index);
                                      return GestureDetector(
                                        onTap: currentPlayer.isCurrentTurn && !_isProcessing
                                            ? () {
                                                setState(() {
                                                  if (isSelected) {
                                                    selectedTableCards.remove(index);
                                                  } else {
                                                    selectedTableCards.add(index);
                                                  }
                                                });
                                              }
                                            : null,
                                        child: _buildCard(
                                          card,
                                          isSelected: isSelected,
                                          isEnabled: currentPlayer.isCurrentTurn && !_isProcessing,
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
                // Info: Soma
                if (selectedHandCard != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange[50],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('Mão: $sum'),
                        Text('Mesa: $tableSum'),
                        Text(
                          'Total: $totalSum',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: totalSum == 15 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
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
                        const Text(
                          'Sua Mão',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: currentPlayer.hand.isEmpty
                              ? const Center(
                                  child: Text('Sem cartas'),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    currentPlayer.hand.length,
                                    (index) {
                                      final card = currentPlayer.hand[index];
                                      final isSelected = selectedHandCard == index;
                                      return GestureDetector(
                                        onTap: currentPlayer.isCurrentTurn && !_isProcessing
                                            ? () {
                                                setState(() {
                                                  if (isSelected) {
                                                    selectedHandCard = null;
                                                  } else {
                                                    selectedHandCard = index;
                                                    selectedTableCards.clear();
                                                  }
                                                });
                                              }
                                            : null,
                                        child: _buildCard(
                                          card,
                                          isSelected: isSelected,
                                          isEnabled: currentPlayer.isCurrentTurn && !_isProcessing,
                                          color: Colors.deepPurple,
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
                              onPressed: currentPlayer.isCurrentTurn && !_isProcessing && selectedHandCard != null
                                  ? () => _makeMove(gameState)
                                  : null,
                              icon: const Icon(Icons.check),
                              label: const Text('Jogar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: currentPlayer.isCurrentTurn && !_isProcessing
                                  ? () => _passMove(gameState)
                                  : null,
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
      ),
    );
  }

  Widget _buildCard(
    dynamic card, {
    required bool isSelected,
    required bool isEnabled,
    Color? color,
  }) {
    return Container(
      width: 70,
      height: 100,
      decoration: BoxDecoration(
        color: isSelected
            ? (color ?? Colors.white).withOpacity(0.3)
            : (color ?? Colors.white),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey,
          width: isSelected ? 3 : 2,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.5),
                  blurRadius: 8,
                )
              ]
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.rank.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color != null ? Colors.white : Colors.black,
              ),
            ),
            Text(
              card.suit.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: color != null ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
