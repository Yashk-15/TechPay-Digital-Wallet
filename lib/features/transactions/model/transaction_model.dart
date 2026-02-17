import 'package:flutter/material.dart';

class TransactionModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final IconData icon;
  final Color color;
  final String type; // 'sent', 'received', 'pending'

  const TransactionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.color,
    required this.type,
  });
}
