import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/detection.dart';
import '../models/drug.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'add_medication_screen.dart';
import 'drug_detail_screen.dart';

class DetectionResultScreen extends StatefulWidget {
  const DetectionResultScreen({
    super.key,
    required this.bytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.result,
  });

  final Uint8List bytes;
  final int imageWidth;
  final int imageHeight;
  final PredictResult result;

  @override
  State<DetectionResultScreen> createState() => _DetectionResultScreenState();
}

class _DetectionResultScreenState extends State<DetectionResultScreen> {
  final Map<int, InteractionResult> _interactions = {};
  final Map<int, String> _interactionErrors = {};
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadInteractions);
  }

  Future<void> _loadInteractions() async {
    final detections = widget.result.detections;
    if (detections.isEmpty) return;
    setState(() => _checking = true);
    final store = context.read<AppState>();
    try {
      await store.loadMedications();
    } catch (_) {}
    if (!mounted) return;
    final currentCodes = store.medications.map((item) => item.kCode).toSet();
    for (var index = 0; index < detections.length; index++) {
      final kCode = detections[index].kCode;
      if (kCode == null) continue;
      final others = currentCodes.where((code) => code != kCode).toList();
      try {
        final result = await store.api.checkInteractions(
          kCode: kCode,
          compareKCodes: others,
        );
        _interactions[index] = result;
      } on ApiException catch (error) {
        _interactionErrors[index] = error.message;
      }
    }
    if (!mounted) return;
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final detections = widget.result.detections;
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.page, 0, AppSpace.page, 28),
        children: [
          const Text('약품을 찾았어요', style: AppType.screen),
          const SizedBox(height: 8),
          const Text('AI 분석 결과를 확인해주세요.', style: AppType.caption),
          const SizedBox(height: 18),
          if (!widget.result.detected || detections.isEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.memory(widget.bytes, height: 220, width: double.infinity, fit: BoxFit.cover),
            ),
            const EmptyHint(
              icon: Icons.search_off_outlined,
              message: '사진에서 학습된 약을 찾지 못했습니다.\n다른 각도나 더 밝은 사진으로 다시 시도해 보세요.',
            ),
          ] else
            for (var index = 0; index < detections.length; index++) ...[
              _ResultCard(
                bytes: widget.bytes,
                imageWidth: widget.imageWidth,
                imageHeight: widget.imageHeight,
                detection: detections[index],
                checking: _checking,
                interaction: _interactions[index],
                interactionError: _interactionErrors[index],
              ),
              const SizedBox(height: 14),
            ],
          const DisclaimerText(),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.bytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.detection,
    required this.checking,
    required this.interaction,
    required this.interactionError,
  });

  final Uint8List bytes;
  final int imageWidth;
  final int imageHeight;
  final Detection detection;
  final bool checking;
  final InteractionResult? interaction;
  final String? interactionError;

  @override
  Widget build(BuildContext context) {
    final drug = detection.drug;
    final low = detection.confidence < AppConfig.lowConfidenceThreshold;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PillCrop(
            bytes: bytes,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            box: detection.bbox,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Text(
            drug?.name ?? '연결된 의약품 정보가 없습니다.',
            style: AppType.screen.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadge(formatConfidence(detection.confidence)),
              if (drug?.etcOtc != null) AppBadge(drug!.etcOtc!),
            ],
          ),
          const SizedBox(height: 8),
          const Text('확정적인 의약품 판정이 아닙니다.', style: AppType.caption),
          if (low) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '인식 신뢰도가 낮습니다. 이 결과를 확정적인 약으로 받아들이지 마세요.',
                style: TextStyle(color: AppColors.warningText, height: 1.4),
              ),
            ),
          ],
          if (drug != null && drug.ingredients.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('성분', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            for (final ingredient in drug.ingredients)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(ingredient),
              ),
          ],
          const SizedBox(height: 12),
          _InteractionBlock(
            checking: checking,
            interaction: interaction,
            error: interactionError,
            hasDrug: drug != null,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: detection.canSave
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DrugDetailScreen(
                          kCode: detection.kCode!,
                          recognitionConfidence: detection.confidence,
                        ),
                      ),
                    );
                  }
                : null,
            child: const Text('상세정보 보기'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: detection.canSave
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddMedicationScreen(
                          kCode: detection.kCode!,
                          name: drug!.name,
                        ),
                      ),
                    );
                  }
                : null,
            child: const Text('내 복용약에 추가'),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillCrop extends StatelessWidget {
  const _PillCrop({
    required this.bytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.box,
  });

  final Uint8List bytes;
  final int imageWidth;
  final int imageHeight;
  final BoundingBox box;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const viewHeight = 168.0;
        final viewWidth = constraints.maxWidth;
        if (imageWidth == 0 || imageHeight == 0 || viewWidth <= 0) {
          return Image.memory(bytes, height: viewHeight, width: viewWidth, fit: BoxFit.cover);
        }
        final boxWidth = (box.x2 - box.x1).clamp(1, imageWidth).toDouble();
        final boxHeight = (box.y2 - box.y1).clamp(1, imageHeight).toDouble();
        final scale = (viewWidth / boxWidth < viewHeight / boxHeight
                ? viewWidth / boxWidth
                : viewHeight / boxHeight) *
            0.72;
        final dx = viewWidth / 2 - ((box.x1 + box.x2) / 2) * scale;
        final dy = viewHeight / 2 - ((box.y1 + box.y2) / 2) * scale;
        return ColoredBox(
          color: AppColors.stage,
          child: SizedBox(
            height: viewHeight,
            width: viewWidth,
            child: Stack(
              children: [
                Positioned(
                  left: dx,
                  top: dy,
                  width: imageWidth * scale,
                  height: imageHeight * scale,
                  child: Image.memory(bytes, fit: BoxFit.fill),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InteractionBlock extends StatelessWidget {
  const _InteractionBlock({
    required this.checking,
    required this.interaction,
    required this.error,
    required this.hasDrug,
  });

  final bool checking;
  final InteractionResult? interaction;
  final String? error;
  final bool hasDrug;

  @override
  Widget build(BuildContext context) {
    if (!hasDrug) return const SizedBox.shrink();
    if (checking && interaction == null && error == null) {
      return const Text(
        '상호작용 정보를 확인하고 있습니다.',
        style: TextStyle(color: AppColors.navySoft),
      );
    }
    if (error != null) {
      return Text(error!, style: const TextStyle(color: AppColors.navySoft));
    }
    final items = interaction?.interactions ?? const [];
    final hasData = interaction?.dataAvailable == true && items.isNotEmpty;
    if (!hasData) {
      return const Text(
        '확인된 상호작용 정보가 없습니다. 안전 여부를 판단한 결과는 아닙니다.',
        style: TextStyle(color: AppColors.navySoft, height: 1.4),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('함께 복용 시 주의', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              item.withCurrentMedication
                  ? "현재 복용 중인 '${item.otherName}'와 함께 복용 시 주의가 필요합니다.\n${item.description}"
                  : '${item.otherName}\n${item.description}',
              style: const TextStyle(height: 1.4),
            ),
          ),
      ],
    );
  }
}
