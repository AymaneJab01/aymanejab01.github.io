# Expense Splitter

A Flutter application for managing shared group expenses.

## Features

- Add people
- Add shared expenses
- Select who paid
- Select who participates
- Automatically calculate individual shares
- Calculate balances
- Minimize the number of required transfers
- Responsive desktop/mobile interface
- Material 3 design

## Architecture

```text
lib/
├── main.dart
├── models/
│   ├── person.dart
│   └── expense.dart
├── services/
│   └── settlement_service.dart
├── screens/
│   └── home_screen.dart
└── widgets/
    ├── summary_card.dart
    ├── person_chip.dart
    ├── expense_card.dart
    └── settlement_card.dart