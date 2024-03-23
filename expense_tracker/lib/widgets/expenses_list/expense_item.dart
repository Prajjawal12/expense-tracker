import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

/// Widget for displaying an individual expense item.
class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final NumberFormat currencyFormat;

  ExpenseItem({
    required this.expense,
    required this.currencyFormat,
  });

  /// Displays the description of the expense in a modal bottom sheet.
  void _showExpenseDescription(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Description:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                expense.description.isNotEmpty
                    ? expense.description
                    : 'No description available',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Category: ${expense.category.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showExpenseDescription(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Text('${currencyFormat.format(expense.amount)}'),
                  const Spacer(),
                  Icon(categoryIcons[expense.category]),
                  const Spacer(),
                  Text(expense.formattedDate),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
