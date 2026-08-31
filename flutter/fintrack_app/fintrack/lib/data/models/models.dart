/// All app models live in one file for now — small, easy to scan,
/// and easy to split into separate files later if the app grows.

class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final bool isIncome;
  final DateTime date;
  final int? accountId;

  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.isIncome,
    required this.date,
    this.accountId,
  });

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    bool? isIncome,
    DateTime? date,
    int? accountId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      isIncome: isIncome ?? this.isIncome,
      date: date ?? this.date,
      accountId: accountId ?? this.accountId,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'isIncome': isIncome ? 1 : 0,
        'date': date.toIso8601String(),
        'accountId': accountId,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
        id: map['id'] as int?,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String,
        isIncome: (map['isIncome'] as int) == 1,
        date: DateTime.parse(map['date'] as String),
        accountId: map['accountId'] as int?,
      );
}

class AccountModel {
  final int? id;
  final String name;
  final String type;
  final String last4;
  final double balance;
  final int colorValue;

  const AccountModel({
    this.id,
    required this.name,
    required this.type,
    required this.last4,
    required this.balance,
    required this.colorValue,
  });

  AccountModel copyWith({
    int? id,
    String? name,
    String? type,
    String? last4,
    double? balance,
    int? colorValue,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      last4: last4 ?? this.last4,
      balance: balance ?? this.balance,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'last4': last4,
        'balance': balance,
        'colorValue': colorValue,
      };

  factory AccountModel.fromMap(Map<String, dynamic> map) => AccountModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        type: map['type'] as String,
        last4: map['last4'] as String,
        balance: (map['balance'] as num).toDouble(),
        colorValue: map['colorValue'] as int,
      );
}

class BudgetModel {
  final int? id;
  final String category;
  final double limit;
  final double spent;

  const BudgetModel({
    this.id,
    required this.category,
    required this.limit,
    this.spent = 0,
  });

  BudgetModel copyWith({int? id, String? category, double? limit, double? spent}) {
    return BudgetModel(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'limit': limit,
        'spent': spent,
      };

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
        id: map['id'] as int?,
        category: map['category'] as String,
        limit: (map['limit'] as num).toDouble(),
        spent: (map['spent'] as num).toDouble(),
      );
}

class GoalModel {
  final int? id;
  final String name;
  final double target;
  final double saved;
  final DateTime? deadline;

  const GoalModel({
    this.id,
    required this.name,
    required this.target,
    this.saved = 0,
    this.deadline,
  });

  GoalModel copyWith({
    int? id,
    String? name,
    double? target,
    double? saved,
    DateTime? deadline,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      target: target ?? this.target,
      saved: saved ?? this.saved,
      deadline: deadline ?? this.deadline,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'target': target,
        'saved': saved,
        'deadline': deadline?.toIso8601String(),
      };

  factory GoalModel.fromMap(Map<String, dynamic> map) => GoalModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        target: (map['target'] as num).toDouble(),
        saved: (map['saved'] as num).toDouble(),
        deadline: map['deadline'] == null ? null : DateTime.parse(map['deadline'] as String),
      );
}

class UserProfile {
  final String name;
  final String email;
  final String phone;

  const UserProfile({required this.name, required this.email, required this.phone});

  UserProfile copyWith({String? name, String? email, String? phone}) => UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );
}
