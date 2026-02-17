import 'package:flutter/material.dart';

enum CardType { visa, mastercard, rupay }

class CardModel {
  final String id;
  final String holderName;
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final CardType type;
  final List<Color> gradientColors;

  const CardModel({
    required this.id,
    required this.holderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.type,
    required this.gradientColors,
  });

  String get maskedNumber =>
      '•••• ${cardNumber.substring(cardNumber.length - 4)}';
}
