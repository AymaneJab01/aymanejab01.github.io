import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class AddAccountScreen extends StatefulWidget {
  final AccountModel? existing;
  const AddAccountScreen({super.key, this.existing});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _last4Ctrl;
  late final TextEditingController _balanceCtrl;
  late String _type;
  late Color _color;

  static const _palette = [
    AppColors.darkGreen,
    AppColors.oliveDark,
    Color(0xFF3B5BA5),
    Color(0xFF8B5CF6),
    Color(0xFFB7791F),
  ];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _last4Ctrl = TextEditingController(text: e?.last4 ?? '');
    _balanceCtrl = TextEditingController(text: e != null ? e.balance.toStringAsFixed(2) : '');
    _type = e?.type ?? AppConstants.accountTypes.first;
    _color = e != null ? Color(e.colorValue) : _palette.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _last4Ctrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AccountRepository>();

    return DetailScaffold(
      title: _isEditing ? 'Edit account' : 'Add account',
      actions: _isEditing
          ? [
              IconButton(
                tooltip: 'Delete',
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
              decoration: const InputDecoration(labelText: 'Account name', hintText: 'e.g. Main Card'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Account type'),
              items: AppConstants.accountTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _last4Ctrl,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Last 4 digits', hintText: '7869'),
              validator: (v) => (v == null || v.trim().length != 4) ? 'Enter exactly 4 digits' : null,
            ),
            TextFormField(
              controller: _balanceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Starting balance', prefixText: '\$ '),
              validator: (v) => (double.tryParse(v ?? '') == null) ? 'Enter a valid amount' : null,
            ),
            const SizedBox(height: 16),
            const Text('Card color', style: TextStyle(color: AppColors.mutedText)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _palette.map((c) {
                final selected = c.value == _color.value;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: c,
                    child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final model = AccountModel(
                  id: widget.existing?.id,
                  name: _nameCtrl.text.trim(),
                  type: _type,
                  last4: _last4Ctrl.text.trim(),
                  balance: double.parse(_balanceCtrl.text),
                  colorValue: _color.value,
                );
                if (_isEditing) {
                  await repo.update(model);
                } else {
                  await repo.add(model);
                }
                if (context.mounted) context.pop();
              },
              child: Text(_isEditing ? 'Save changes' : 'Add account'),
            ),
          ],
        ),
      ),
    );
  }
}
