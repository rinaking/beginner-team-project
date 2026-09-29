import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.color = AppColors.card,
    this.padding = const EdgeInsets.all(AppSpace.card),
    this.onTap,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpace.radius),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C1B2A4A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpace.radius),
        child: card,
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.navy,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class MutedText extends StatelessWidget {
  const MutedText(this.text, {super.key, this.size = 14});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: AppColors.navySoft, fontSize: size, height: 1.45),
    );
  }
}

class AppBadge extends StatelessWidget {
  const AppBadge(this.label, {super.key, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.primaryDeep),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryDeep,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.text, this.icon = Icons.info_outline});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(AppSpace.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: MutedText(text, size: 13)),
        ],
      ),
    );
  }
}

class PendingNotice extends StatelessWidget {
  const PendingNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 15, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              '정보 업데이트 예정',
              style: TextStyle(
                color: AppColors.primaryDeep,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.mint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 34),
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: AppType.caption),
        ],
      ),
    );
  }
}

class DisclaimerText extends StatelessWidget {
  const DisclaimerText({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text ??
          '이 앱은 의료 전문가의 판단을 대신하지 않습니다. 현재 학습된 의약품만 찾을 수 있습니다.',
      style: const TextStyle(color: AppColors.muted, height: 1.45, fontSize: 12),
    );
  }
}

class AnalysisStatus extends StatelessWidget {
  const AnalysisStatus({super.key, required this.activeStep});

  final int activeStep;

  static const steps = ['이미지 준비', '약품 탐지', '의약품 정보 확인'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const _AnalysisMark(),
        const SizedBox(height: 28),
        const Text('AI가 약품을\n분석하고 있어요', textAlign: TextAlign.center, style: AppType.hero),
        const SizedBox(height: 10),
        const Text('잠시만 기다려주세요.', style: AppType.caption),
        const SizedBox(height: 36),
        for (var index = 0; index < steps.length; index++)
          _StepRow(
            label: steps[index],
            done: index < activeStep,
            active: index == activeStep,
            last: index == steps.length - 1,
          ),
      ],
    );
  }
}

class _AnalysisMark extends StatelessWidget {
  const _AnalysisMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            left: 18,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 16,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.stage,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 38),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.done,
    required this.active,
    required this.last,
  });

  final String label;
  final bool done;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = done || active ? AppColors.primary : AppColors.muted;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.circle_outlined,
                  color: color,
                  size: 22,
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: done ? AppColors.mintStrong : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 22, top: 1),
              child: Text(
                label,
                style: TextStyle(
                  color: done || active ? AppColors.navy : AppColors.muted,
                  fontSize: 16,
                  fontWeight: done || active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
