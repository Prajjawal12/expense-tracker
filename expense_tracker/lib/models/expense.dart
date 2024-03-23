import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// Generate unique identifiers
const uuid = Uuid();

// Formatter for date display
final formatter = DateFormat.yMd();

// Enum defining expense categories
enum Category { food, work, leisure, travel }

// Icons corresponding to expense categories
const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.movie,
  Category.work: Icons.work
};

/// Represents an individual expense.
class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.description,
    required this.currency,
  }) : id = uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final String description;
  final Currency? currency;

  /// Gets the formatted date string of the expense.
  String get formattedDate {
    return formatter.format(date);
  }
}

/// Represents a group of expenses under a specific category.
class ExpenseBucket {
  const ExpenseBucket({
    required this.category,
    required this.expenses,
  });

  final Category category;
  final List<Expense> expenses;

  /// Constructs an ExpenseBucket for a specific category from a list of all expenses.
  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  /// Calculates the total expenses within the bucket.
  double get totalExpenses {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
