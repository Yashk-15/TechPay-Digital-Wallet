import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../model/card_model.dart';

class CardsState {
  final List<CardModel> cards;
  final bool isLoading;

  const CardsState({
    this.cards = const [],
    this.isLoading = false,
  });
}

class CardsController extends StateNotifier<CardsState> {
  CardsController() : super(const CardsState()) {
    _loadInitialCards();
  }

  void _loadInitialCards() {
    // Mock initial data matching the design
    final initialCards = [
      const CardModel(
        id: '1',
        holderName: 'Jon Snow',
        cardNumber: '4582159635744582',
        expiryDate: '12/25',
        cvv:
            '123', // WARNING: storing CVV in plain text is for DEMO ONLY. Do not do this in production.
        type: CardType.mastercard,
        gradientColors: [
          AppTheme.bgAbyss,
          AppTheme.bgElevated,
        ], // Primary Gradient approximation
      ),
      const CardModel(
        id: '12',
        holderName: 'Jon Snow',
        cardNumber: '8765432109878765',
        expiryDate: '08/26',
        cvv: '456',
        type: CardType.visa,
        gradientColors: [AppTheme.bgElevated, AppTheme.bgSurface], // Secondary
      ),
    ];
    state = CardsState(cards: initialCards);
  }

  void addCard(CardModel card) {
    state = CardsState(
      cards: [...state.cards, card],
      isLoading: state.isLoading,
    );
  }
}

final cardsProvider = StateNotifierProvider<CardsController, CardsState>((ref) {
  return CardsController();
});
