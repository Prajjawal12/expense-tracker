part of 'expense_bloc.dart';

/// Represents events related to expenses.
@immutable
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load expenses.
class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();

  @override
  List<Object?> get props => [];
}

/// Event to add an expense.
class AddExpense extends ExpenseEvent {
  final Expense expense;

  const AddExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

/// Event to delete an expense.
class DeleteExpense extends ExpenseEvent {
  final Expense expense;

  const DeleteExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}
