import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class AddGoalScreen extends StatefulWidget {
  final GoalModel? existing;
  const AddGoalScreen({super.key, this.existing});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _savedCtrl;
  DateTime? _deadline;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _targetCtrl = TextEditingController(text: e != null ? e.target.toStringAsFixed(2) : '');
    _savedCtrl = TextEditingController(text: e != null ? e.saved.toStringAsFixed(2) : '0');
    _deadline = e?.deadline;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _savedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<GoalRepository>();

    return DetailScaffold(
      title: _isEditing ? 'Edit goal' : 'Add goal',
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
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal name', hintText: 'e.g. New laptop'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Target amount', prefixText: '\$ '),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                return (n == null || n <= 0) ? 'Enter a valid amount' : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _savedCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Already saved (optional)', prefixText: '\$ '),
              validator: (v) => (double.tryParse(v ?? '0') == null) ? 'Enter a valid amount' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Target date (optional)'),
              subtitle: Text(_deadline == null
                  ? 'Not set'
                  : '${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final model = GoalModel(
                  id: widget.existing?.id,
                  name: _nameCtrl.text.trim(),
                  target: double.parse(_targetCtrl.text),
                  saved: double.tryParse(_savedCtrl.text) ?? 0,
                  deadline: _deadline,
                );
                if (_isEditing) {
                  await repo.update(model);
                } else {
                  await repo.add(model);
                }
                if (context.mounted) context.pop();
              },
              child: Text(_isEditing ? 'Save changes' : 'Add goal'),
            ),
          ],
        ),
      ),
    );
  }
}
