import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medication.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({
    super.key,
    required this.kCode,
    required this.name,
    this.existing,
  });

  final String kCode;
  final String name;
  final Medication? existing;

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _useEndDate;
  late List<String> _times;
  late final TextEditingController _memo;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _startDate = existing == null ? DateTime.now() : parseIsoDate(existing.startDate);
    _endDate = existing?.endDate == null ? null : parseIsoDate(existing!.endDate!);
    _useEndDate = _endDate != null;
    _times = existing == null ? <String>[] : List<String>.from(existing.times)..sort();
    _memo = TextEditingController(text: existing?.memo ?? '');
  }

  @override
  void dispose() {
    _memo.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _useEndDate = true;
      });
    }
  }

  Future<void> _pickTime({int? replaceIndex}) async {
    final current = replaceIndex == null ? null : _parseTime(_times[replaceIndex]);
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? const TimeOfDay(hour: 8, minute: 0),
      initialEntryMode: TimePickerEntryMode.input,
      helpText: '복용 시간',
      cancelText: '취소',
      confirmText: '확인',
      hourLabelText: '시',
      minuteLabelText: '분',
      errorInvalidText: '올바른 시간을 입력해 주세요.',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked == null) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    final duplicated = _times.asMap().entries.any(
          (entry) => entry.value == value && entry.key != replaceIndex,
        );
    if (duplicated) {
      setState(() => _error = '같은 복용 시간이 이미 있습니다.');
      return;
    }
    setState(() {
      final next = List<String>.from(_times);
      if (replaceIndex == null) {
        next.add(value);
      } else {
        next[replaceIndex] = value;
      }
      next.sort();
      _times = next;
      _error = null;
    });
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _save() async {
    if (_times.isEmpty) {
      setState(() => _error = '복용 시간을 하나 이상 입력해 주세요.');
      return;
    }
    if (_useEndDate && _endDate == null) {
      setState(() => _error = '복용 종료일을 선택해 주세요.');
      return;
    }
    if (_useEndDate && _endDate!.isBefore(DateTime(_startDate.year, _startDate.month, _startDate.day))) {
      setState(() => _error = '복용 종료일은 시작일보다 빠를 수 없습니다.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final api = context.read<AppState>().api;
    final memo = _memo.text.trim();
    try {
      if (widget.existing == null) {
        await api.createMedication(
          kCode: widget.kCode,
          startDate: toIsoDate(_startDate),
          endDate: _useEndDate ? toIsoDate(_endDate!) : null,
          times: _times,
          memo: memo.isEmpty ? null : memo,
        );
      } else {
        await api.updateMedication(
          id: widget.existing!.id,
          kCode: widget.kCode,
          startDate: toIsoDate(_startDate),
          endDate: _useEndDate ? toIsoDate(_endDate!) : null,
          times: _times,
          memo: memo.isEmpty ? null : memo,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.page, 4, AppSpace.page, 28),
        children: [
          Text(editing ? '복용약 수정' : '내 복용약에 추가', style: AppType.brand),
          const SizedBox(height: 6),
          Text(widget.name, style: AppType.screen),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('복용 시작일'),
            subtitle: Text(formatDotDate(toIsoDate(_startDate))),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _saving ? null : _pickStart,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('종료일 지정'),
            value: _useEndDate,
            onChanged: _saving
                ? null
                : (value) => setState(() {
                      _useEndDate = value;
                      _error = null;
                    }),
          ),
          if (_useEndDate)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('복용 종료일'),
              subtitle: Text(_endDate == null ? '날짜를 선택하세요' : formatDotDate(toIsoDate(_endDate!))),
              trailing: const Icon(Icons.event_outlined),
              onTap: _saving ? null : _pickEnd,
            ),
          const SizedBox(height: 8),
          const Text('복용 시간', style: AppType.section),
          const SizedBox(height: 4),
          const Text(
            '하루 여러 번이라면 시간을 하나씩 추가하세요. 시간은 빠른 순서로 정렬됩니다.',
            style: AppType.caption,
          ),
          const SizedBox(height: 12),
          if (_times.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('추가된 복용 시간이 없습니다.', style: AppType.caption),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < _times.length; index++)
                  _TimeChip(
                    label: _times[index],
                    onEdit: _saving ? null : () => _pickTime(replaceIndex: index),
                    onDelete: _saving
                        ? null
                        : () => setState(() {
                              _times = List<String>.from(_times)..removeAt(index);
                              _error = null;
                            }),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _saving ? null : () => _pickTime(),
              icon: const Icon(Icons.add),
              label: const Text('시간 추가'),
            ),
          ),
          TextField(
            controller: _memo,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: '메모 (선택)',
              alignLabelWithHint: true,
            ),
            minLines: 2,
            maxLines: 4,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '저장 중' : '저장'),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.onEdit,
    required this.onDelete,
  });

  final String label;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primaryDeep,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                tooltip: '시간 삭제',
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 16, color: AppColors.primaryDeep),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
