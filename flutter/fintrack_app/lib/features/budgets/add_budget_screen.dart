import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class AddBudgetScreen extends StatefulWidget {
  final BudgetModel? existing;
  const AddBudgetScreen({super.key, this.existing});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _category;
  late final TextEditingController _limitCtrl;
  late final TextEditingController _spentCtrl;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _category = e?.category ?? AppConstants.expenseCategories.first;
    _limitCtrl = TextEditingController(text: e != null ? e.limit.toStringAsFixed(2) : '');
    _spentCtrl = TextEditingController(text: e != null ? e.spent.toStringAsFixed(2) : '0');
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    _spentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<BudgetRepository>();

    return DetailScaffold(
      title: _isEditing ? 'Edit budget' : 'Add budget',
      actions: _isEditing
          ? [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () async {
                  await repo.delete(widget.existing!.id!);
                  if (context.mounted) context.pop();
                },
              ),
            ]
          : null,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: AppConstants.expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _limitCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monthly limit', prefixText: '\$ '),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                return (n == null || n <= 0) ? 'Enter a valid limit' : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _spentCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Already spent (optional)', prefixText: '\$ '),
              validator: (v) => (double.tryParse(v ?? '0') == null) ? 'Enter a valid amount' : null,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final model = BudgetModel(
                  id: widget.existing?.id,
                  category: _category,
                  limit: double.parse(_limitCtrl.text),
                  spent: double.tryParse(_spentCtrl.text) ?? 0,
                );
                if (_isEditing) {
                  await repo.update(model);
                } else {
                  await repo.add(model);
                }
                if (context.mounted) context.pop();
              },
              child: Text(_isEditing ? 'Save changes' : 'Add budget'),
            ),
          ],
        ),
      ),
    );
  }
}
