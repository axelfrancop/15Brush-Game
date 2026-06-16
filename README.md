# Card Game Multiplayer (15Brush-Game)

Um jogo de cartas multiplayer em tempo real para Android e iOS, desenvolvido com Flutter, Flame e Firebase.

## 🚀 Tecnologias

- **Flutter**: Framework principal
- **Flame**: Game engine para renderização e game loop
- **Firebase**: Backend para multiplayer em tempo real
  - Firestore: Banco de dados em tempo real
  - Firebase Auth: Autenticação
- **Provider**: State management

## 📁 Estrutura do Projeto

```
lib/
├── models/              # Modelos de dados (Card, Player, GameState)
├── screens/             # Telas da aplicação
├── services/            # Serviços (Firebase)
├── widgets/             # Widgets reutilizáveis
├── game/                # Lógica do jogo (Flame)
├── utils/               # Utilitários
└── main.dart            # Ponto de entrada
```

## 📋 Setup

### Pré-requisitos
- Flutter SDK 3.12+
- Dart 3.12+
- Firebase Project

### Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/axelfrancop/15Brush-Game.git
   cd 15Brush-Game
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Configure o Firebase**
   ```bash
   flutterfire configure
   ```
   Siga as instruções para conectar seu projeto Firebase.

4. **Execute a aplicação**
   ```bash
   flutter run
   ```

## 🎮 Features (To-Do)

- [ ] Autenticação com Firebase
- [ ] Criar/Jogar partidas multiplayer
- [ ] Sistema de turnos
- [ ] Renderização das cartas com Flame
- [ ] Chat em jogo
- [ ] Ranking de jogadores
- [ ] Histórico de partidas

## 🃏 Regras do Jogo

*A serem definidas*

## 🤝 Contribuindo

Este é um projeto em desenvolvimento. Alterações devem ser feitas via commits no Git.

## 📝 Notas

- Use `flutter clean` se encontrar problemas de build
- O Firebase precisa ser configurado em `ios/GoogleService-Info.plist` e `android/app/google-services.json`
