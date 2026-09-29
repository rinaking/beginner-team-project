import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/medication.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenScanner});

  final VoidCallback onOpenScanner;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AppState>().loadToday();
    });
  }

  Future<void> _mark(Dose dose, {required bool taken}) async {
    final store = context.read<AppState>();
    final error = taken ? await store.markTaken(dose) : await store.cancelTaken(dose);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppState>();
    final now = DateTime.now();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: store.loadToday,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.page, 12, AppSpace.page, 32),
          children: [
            Row(
              children: [
                const Text('DailyPills', style: AppType.brand),
                const Spacer(),
                IconButton(
                  tooltip: '복용 기록',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.calendar_month_outlined, color: AppColors.navy),
                ),
              ],
            ),
            const Text('오늘도 잊지 말고\n약 챙겨 드세요', style: AppType.hero),
            const SizedBox(height: 10),
            Text(formatKoreanDate(now), style: AppType.caption),
            const SizedBox(height: 28),
            const Text('오늘의 복약', style: AppType.section),
            const SizedBox(height: 14),
            if (store.todayError != null)
              EmptyHint(icon: Icons.cloud_off_outlined, message: store.todayError!),
            if (store.loadingToday && store.today.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (store.today.isEmpty && store.todayError == null)
              const _TodayEmpty()
            else
              for (final dose in store.today) ...[
                _DoseCard(
                  dose: dose,
                  pending: store.pendingDoseKeys.contains(
                    '${dose.medicationId}-${dose.date}-${dose.scheduledTime}',
                  ),
                  onTaken: () => _mark(dose, taken: true),
                  onCancel: () => _mark(dose, taken: false),
                ),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 8),
            _PhotoFeature(onTap: widget.onOpenScanner),
          ],
        ),
      ),
    );
  }
}

class _TodayEmpty extends StatelessWidget {
  const _TodayEmpty();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 20),
      child: Column(
        children: [
          Icon(Icons.event_available_outlined, color: AppColors.primary, size: 36),
          SizedBox(height: 12),
          Text('오늘 예정된 복용약이 없어요', style: AppType.title, textAlign: TextAlign.center),
          SizedBox(height: 6),
          Text(
            '등록한 복용약이 있으면 여기에 표시됩니다.',
            style: AppType.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PhotoFeature extends StatelessWidget {
  const _PhotoFeature({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.photo_camera_outlined, color: AppColors.primary, size: 34),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('약 사진으로 찾기', style: AppType.title),
                    SizedBox(height: 4),
                    Text('사진 한 장으로 의약품을 확인해보세요', style: AppType.caption),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoseCard extends StatelessWidget {
  const _DoseCard({
    required this.dose,
    required this.pending,
    required this.onTaken,
    required this.onCancel,
  });

  final Dose dose;
  final bool pending;
  final VoidCallback onTaken;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final taken = dose.taken;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 104,
              color: taken ? AppColors.mint : AppColors.timeWell,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
              child: Text(
                dose.scheduledTime,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dose.name, style: AppType.title),
                    const SizedBox(height: 6),
                    if (taken)
                      const AppBadge('복용 완료', icon: Icons.check)
                    else
                      const Text('아직 복용하지 않았어요', style: AppType.caption),
                    if (taken && dose.takenAt != null) ...[
                      const SizedBox(height: 6),
                      Text('${formatClock(dose.takenAt!)}에 기록', style: AppType.caption),
                    ],
                    const SizedBox(height: 12),
                    if (taken)
                      TextButton(
                        onPressed: pending ? null : onCancel,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('체크 취소'),
                      )
                    else
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: pending ? null : onTaken,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(120, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: pending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('복용 완료'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
