import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import 'lobby_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _playerNameController = TextEditingController();
  final _gameIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _playerNameController.dispose();
    _gameIdController.dispose();
    super.dispose();
  }

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

  Future<void> _createGame() async {
    final playerName = _playerNameController.text.trim();
    if (playerName.isEmpty) {
      _showError('Por favor, digite seu nome');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseService = context.read<FirebaseService>();
      final gameId = await firebaseService.createGame(playerName);

      if (mounted) {
        _showSuccess('Jogo criado!');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LobbyScreen(gameId: gameId, playerName: playerName),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro ao criar jogo: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _joinGame() async {
    final gameId = _gameIdController.text.trim();
    final playerName = _playerNameController.text.trim();

    if (gameId.isEmpty || playerName.isEmpty) {
      _showError('Por favor, preencha todos os campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseService = context.read<FirebaseService>();
      await firebaseService.joinGame(gameId, playerName);

      if (mounted) {
        _showSuccess('Entrou no jogo!');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LobbyScreen(gameId: gameId, playerName: playerName),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro ao entrar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('15 Brush Game'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Center(
              child: Text(
                '🃏',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bem-vindo ao Jogo de Cartas',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _playerNameController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Seu Nome',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createGame,
              icon: const Icon(Icons.add_circle),
              label: const Text('Criar Novo Jogo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                disabledBackgroundColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OU',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _gameIdController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'ID do Jogo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.key),
                hintText: 'Cole o ID do jogo',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _joinGame,
              icon: const Icon(Icons.login),
              label: const Text('Entrar em Jogo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
                disabledBackgroundColor: Colors.grey,
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Center(
                  child: Column(
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Carregando...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
