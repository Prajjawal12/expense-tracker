part of 'expense_bloc.dart';

/// Represents the state of expenses.
@immutable
abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object> get props => [];
}

/// Initial state when no expenses are loaded.
class ExpenseInitial extends ExpenseState {}

/// State when expenses are successfully loaded.
class ExpensesLoaded extends ExpenseState {
  final List<Expense> expenses;

  const ExpensesLoaded({required this.expenses});

  @override
  List<Object> get props => [expenses];
}

/// State when an error occurs while loading or managing expenses.
class ExpensesError extends ExpenseState {
  final String message;

  const ExpensesError({required this.message});

  @override
  List<Object> get props => [message];
}
