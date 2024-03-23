import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'expense_event.dart';
part 'expense_state.dart';

/// Manages the state of expenses.
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  /// Shared preferences instance for storing expenses.
  final SharedPreferences sharedPreferences;

  /// Constructs an instance of [ExpenseBloc].
  ExpenseBloc({required this.sharedPreferences}) : super(ExpenseInitial()) {
    on<LoadExpenses>(_mapLoadExpensesToState);
    on<AddExpense>(_mapAddExpenseToState);
    on<DeleteExpense>(_mapDeleteExpenseToState);
  }

  /// Loads expenses from SharedPreferences.
  FutureOr<void> _mapLoadExpensesToState(
      LoadExpenses event, Emitter<ExpenseState> emit) async {
    try {
      final List<String>? jsonStringList =
          sharedPreferences.getStringList('expenses');
      if (jsonStringList != null) {
        final List<Expense> expenses = jsonStringList.map((jsonString) {
          final Map<String, dynamic> json = jsonDecode(jsonString);
          return Expense(
            title: json['title'],
            amount: json['amount'],
            date: DateTime.parse(json['date']),
            currency: null,
            description: '',
            category: Category.food,
            // Add other fields as needed
          );
        }).toList();
        emit(ExpensesLoaded(expenses: expenses));
      } else {
        emit(const ExpensesLoaded(expenses: []));
      }
    } catch (e) {
      emit(ExpensesError(message: 'Failed to load expenses: $e'));
    }
  }

  /// Adds an expense to the list of expenses.
  FutureOr<void> _mapAddExpenseToState(
      AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      final currentState = state;
      if (currentState is ExpensesLoaded) {
        final updatedExpenses = List<Expense>.from(currentState.expenses)
          ..add(event.expense);
        await _saveExpensesToPrefs(updatedExpenses);
        emit(ExpensesLoaded(expenses: updatedExpenses));
      }
    } catch (e) {
      emit(ExpensesError(message: 'Failed to add expense: $e'));
    }
  }

  /// Deletes an expense from the list of expenses.
  FutureOr<void> _mapDeleteExpenseToState(
      DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      final currentState = state;
      if (currentState is ExpensesLoaded) {
        final updatedExpenses = List<Expense>.from(currentState.expenses)
          ..remove(event.expense);
        await _saveExpensesToPrefs(updatedExpenses);
        emit(ExpensesLoaded(expenses: updatedExpenses));
      }
    } catch (e) {
      emit(ExpensesError(message: 'Failed to delete expense: $e'));
    }
  }

  /// Saves expenses to SharedPreferences.
  Future<void> _saveExpensesToPrefs(List<Expense> expenses) async {
    try {
      final List<String> jsonStringList = expenses.map((expense) {
        final Map<String, dynamic> json = {
          'title': expense.title,
          'amount': expense.amount,
          'date': expense.date.toIso8601String(),
          'category': expense.category,
          'currency': expense.currency
        };
        return jsonEncode(json);
      }).toList();
      await sharedPreferences.setStringList('expenses', jsonStringList);
    } catch (e) {
      log(e.toString());
    }
  }
}
