import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        cvv: '123',
        type: CardType.mastercard,
        gradientColors: [
          Color(0xFF04322E),
          Color(0xFF1A5C58)
        ], // Primary Gradient approximation
      ),
      const CardModel(
        id: '2',
        holderName: 'Jon Snow',
        cardNumber: '8765432109878765',
        expiryDate: '08/26',
        cvv: '456',
        type: CardType.visa,
        gradientColors: [Color(0xFF1A5C58), Color(0xFF2D8B7A)], // Secondary
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
