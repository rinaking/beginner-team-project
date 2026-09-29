import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medication.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'add_medication_screen.dart';
import 'drug_search_screen.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final store = context.read<AppState>();
      store.loadMedications();
      store.loadToday();
    });
  }

  Future<void> _openSearch() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const DrugSearchScreen()),
    );
    if (saved == true && mounted) {
      await context.read<AppState>().loadMedications();
    }
  }

  Future<void> _edit(Medication medication) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicationScreen(
          kCode: medication.kCode,
          name: medication.name,
          existing: medication,
        ),
      ),
    );
    if (saved == true && mounted) {
      await context.read<AppState>().loadMedications();
    }
  }

  Future<void> _delete(Medication medication) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('복용약 삭제'),
          content: Text('\'${medication.name}\' 복용약을 삭제할까요?\n복용 기록도 함께 삭제됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<AppState>().api.deleteMedication(medication.id);
      if (!mounted) return;
      await context.read<AppState>().loadMedications();
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppState>();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: store.loadMedications,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, 20, AppSpace.page, 28),
          children: [
            const Text('내 복용약', style: AppType.brand),
            const SizedBox(height: 6),
            const Text('현재 복용 중인 약을\n한눈에 확인하세요', style: AppType.hero),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _openSearch,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('약 이름으로 추가'),
              ),
            ),
            const SizedBox(height: 18),
            if (store.medicationsError != null)
              EmptyHint(
                icon: Icons.cloud_off_outlined,
                message: store.medicationsError!,
              )
            else if (store.loadingMedications && store.medications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (store.medications.isEmpty)
              const EmptyHint(
                icon: Icons.medication_outlined,
                message: '등록된 복용약이 없습니다.\n사진으로 찾거나 약 이름으로 추가하세요.',
              )
            else
              for (final medication in store.medications) ...[
                _MedicationTile(
                  medication: medication,
                  onEdit: () => _edit(medication),
                  onDelete: () => _delete(medication),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({
    required this.medication,
    required this.onEdit,
    required this.onDelete,
  });

  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final end = medication.endDate == null
        ? '계속'
        : formatDotDate(medication.endDate!);
    final today = context.watch<AppState>().today.where(
          (dose) => dose.medicationId == medication.id,
        );
    final doses = today.toList();
    final done = doses.where((dose) => dose.taken).length;
    final takenByTime = {for (final dose in doses) dose.scheduledTime: dose.taken};
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(medication.name, style: AppType.title),
          const SizedBox(height: 4),
          Text('${formatDotDate(medication.startDate)} ~ $end', style: AppType.caption),
          if (doses.isNotEmpty && done == doses.length) ...[
            const SizedBox(height: 10),
            const AppBadge('오늘 복용 완료', icon: Icons.check),
          ],
          const SizedBox(height: 12),
          for (final time in medication.times) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (takenByTime[time] == true)
                    const AppBadge('복용 완료', icon: Icons.check)
                  else if (takenByTime.containsKey(time))
                    const Text('복용 예정', style: AppType.caption),
                ],
              ),
            ),
          ],
          if (medication.memo != null && medication.memo!.isNotEmpty)
            Text(medication.memo!, style: AppType.caption),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(onPressed: onEdit, child: const Text('수정')),
              TextButton(onPressed: onDelete, child: const Text('삭제')),
            ],
          ),
        ],
      ),
    );
  }
}
