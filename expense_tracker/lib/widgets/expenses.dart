import 'dart:convert';

import 'package:currency_picker/currency_picker.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/charts/chart.dart';
import 'package:expense_tracker/widgets/expenses_list/expenses_list.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/bloc/bloc/expense_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Expenses extends StatefulWidget {
  const Expenses({Key? key}) : super(key: key);

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  late SharedPreferences _prefs;
  late ExpenseBloc _expenseBloc;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
  }

  Future<void> _initializeDependencies() async {
    _prefs = await SharedPreferences.getInstance();
    _expenseBloc = context.read<ExpenseBloc>();
    // Register event handler for LoadExpenses
    _expenseBloc.on<LoadExpenses>((event, emit) async {
      // For LoadExpenses event, fetch expenses from a data source
      try {
        final expenses = await _fetchExpenses();
        emit(ExpensesLoaded(expenses: expenses));
      } catch (e) {
        emit(ExpensesError(message: 'Failed to load expenses: $e'));
      }
    });
    // Add an event to load expenses
    _expenseBloc.add(LoadExpenses());
  }

  Future<List<Expense>> _fetchExpenses() async {
    final jsonStringList = _prefs.getStringList('expenses');
    if (jsonStringList != null) {
      final expenses = jsonStringList.map((jsonString) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return Expense(
          title: json['title'],
          amount: json['amount'],
          date: DateTime.parse(json['date']),
          category: Category.food,
          description: '',
          currency: Currency(
            code: 'USD',
            name: 'US Dollar',
            symbol: '\$',
            flag: 'US Flag',
            number: 840,
            decimalDigits: 2,
            namePlural: 'US Dollars',
            symbolOnLeft: true,
            decimalSeparator: '.',
            thousandsSeparator: ',',
            spaceBetweenAmountAndSymbol: false,
          ),
        );
      }).toList();
      return expenses;
    } else {
      return []; // Return an empty list if no expenses found
    }
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(
        onAddExpense: _addExpense,
      ),
    );
  }

  void _addExpense(Expense expense) {
    _expenseBloc.add(AddExpense(expense));
  }

  void _removeExpense(Expense expense) {
    _expenseBloc.add(DeleteExpense(expense));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Flutter Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpensesLoaded) {
            final totalExpenses = _calculateTotalExpenses(state.expenses);
            final expensesPerCategory =
                _calculateExpensesPerCategory(state.expenses);
            return _buildContent(
                state.expenses, totalExpenses, expensesPerCategory);
          } else if (state is ExpensesError) {
            return _buildError(state.message);
          } else {
            return _buildLoading(); // Show loading indicator while expenses are loading
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final List<Expense> expenses = await _fetchExpenses();
          final double totalExpenses = _calculateTotalExpenses(expenses);
          final Map<Category, double> expensesPerCategory =
              _calculateExpensesPerCategory(expenses);

          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Expenses Per Category:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...expensesPerCategory.entries.map((entry) {
                      return Text(
                          '${entry.key}: \$${entry.value.toStringAsFixed(2)}');
                    }).toList(),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.summarize),
      ),
    );
  }

  double _calculateTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0, (total, expense) => total + expense.amount);
  }

  Map<Category, double> _calculateExpensesPerCategory(List<Expense> expenses) {
    final Map<Category, double> expensesPerCategory = {};
    expenses.forEach((expense) {
      expensesPerCategory.update(
          expense.category, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    });
    return expensesPerCategory;
  }

  Widget _buildContent(List<Expense> expenses, double totalExpenses,
      Map<Category, double> expensesPerCategory) {
    final width = MediaQuery.of(context).size.width;
    Widget mainContent =
        const Center(child: Text('No expenses found, Start adding some.'));

    if (expenses.isNotEmpty) {
      mainContent = width < 600
          ? Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Chart(expenses: expenses),
                const SizedBox(height: 20),
                Expanded(
                  child: ExpensesList(expenses, _removeExpense),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: Chart(expenses: expenses)),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTotalExpenses(totalExpenses),
                    SizedBox(height: 20),
                    _buildExpensesPerCategory(expensesPerCategory),
                  ],
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ExpensesList(expenses, _removeExpense),
                ),
              ],
            );
    }

    return mainContent;
  }

  Widget _buildTotalExpenses(double totalExpenses) {
    return Text(
      'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildExpensesPerCategory(Map<Category, double> expensesPerCategory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expenses Per Category:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...expensesPerCategory.entries.map((entry) {
          return Text('${entry.key}: \$${entry.value.toStringAsFixed(2)}');
        }).toList(),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Text('Error: $message'),
    );
  }
}
