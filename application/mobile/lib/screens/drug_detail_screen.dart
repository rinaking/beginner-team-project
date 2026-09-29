import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/drug.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'add_medication_screen.dart';

class DrugDetailScreen extends StatefulWidget {
  const DrugDetailScreen({
    super.key,
    required this.kCode,
    this.recognitionConfidence,
  });

  final String kCode;
  final double? recognitionConfidence;

  @override
  State<DrugDetailScreen> createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  DrugDetail? _detail;
  InteractionResult? _interaction;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final api = context.read<AppState>().api;
    final store = context.read<AppState>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await api.drugDetail(widget.kCode);
      if (!mounted) return;
      setState(() => _detail = detail);
      try {
        await store.loadMedications();
      } catch (_) {}
      if (!mounted) return;
      final others = store.medications
          .map((item) => item.kCode)
          .where((code) => code != widget.kCode)
          .toSet()
          .toList();
      final interaction = await api.checkInteractions(
        kCode: widget.kCode,
        compareKCodes: others,
      );
      if (!mounted) return;
      setState(() => _interaction = interaction);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (_detail == null) {
        setState(() => _error = error.message);
      } else {
        setState(() {
          _interaction = InteractionResult(
            dataAvailable: false,
            message: error.message,
            interactions: const <InteractionItem>[],
          );
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    return Scaffold(
      appBar: AppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    EmptyHint(
                      icon: Icons.error_outline,
                      message: _error ?? '약 정보를 불러오지 못했습니다.',
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpace.page, 8, AppSpace.page, 28),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(detail.drug.name, style: AppType.screen),
                          if (detail.drug.nameEn != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              detail.drug.nameEn!,
                              style: const TextStyle(color: AppColors.navySoft),
                            ),
                          ],
                          if (detail.basics.etcOtc != null ||
                              widget.recognitionConfidence != null) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (detail.basics.etcOtc != null) AppBadge(detail.basics.etcOtc!),
                                if (widget.recognitionConfidence != null)
                                  AppBadge(formatConfidence(widget.recognitionConfidence!)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (_basicRows(detail).isNotEmpty) _basicsTable(detail),
                    _section('효능·효과', [
                      _officialText(detail.official.efficacy),
                    ]),
                    _section('용법·용량', [
                      _officialText(detail.official.dosage),
                    ]),
                    _section('사용상 주의사항', [
                      _officialText(detail.official.caution),
                    ]),
                    if (detail.official.beforeUse != null)
                      _section('사용 전 확인', [
                        _bodyText(detail.official.beforeUse!),
                      ]),
                    if (detail.official.sideEffect != null)
                      _section('이상반응', [
                        _bodyText(detail.official.sideEffect!),
                      ]),
                    if (detail.official.interactionNote != null)
                      _section('함께 주의할 약 또는 음식', [
                        _bodyText(detail.official.interactionNote!),
                      ]),
                    if (_interaction != null &&
                        _interaction!.dataAvailable &&
                        _interaction!.interactions.isNotEmpty)
                      _section('상호작용', [
                        _interactionBody(_interaction),
                      ])
                    else if (detail.official.interactionNote == null)
                      _section('상호작용', [
                        _interactionBody(_interaction),
                      ]),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddMedicationScreen(
                              kCode: detail.kCode,
                              name: detail.drug.name,
                            ),
                          ),
                        );
                      },
                      child: const Text('내 복용약에 추가'),
                    ),
                    const SizedBox(height: 16),
                    const DisclaimerText(),
                  ],
                ),
    );
  }

  Widget _interactionBody(InteractionResult? interaction) {
    final items = interaction?.interactions ?? const <InteractionItem>[];
    if (interaction?.dataAvailable == true && items.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    return Text(
      interaction?.message ?? '확인된 상호작용 정보가 없습니다. 안전 여부를 판단한 결과는 아닙니다.',
      style: const TextStyle(color: AppColors.navySoft, height: 1.4),
    );
  }

  List<Widget> _basicRows(DrugDetail detail) {
    final basics = detail.basics;
    return [
      _ingredients(basics),
      _info('제조사', basics.company),
      _info('의약품 분류', basics.classNo),
      _info('성상', basics.chart),
      _info('보관방법', basics.storageMethod),
      _info('유효기간', basics.validTerm),
    ];
  }

  Widget _basicsTable(DrugDetail detail) {
    final rows = _basicRows(detail);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('기본 정보', style: AppType.section),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: rows),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    final visible = children.where((child) => child is! SizedBox).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppType.section),
          const SizedBox(height: 10),
          ...visible,
        ],
      ),
    );
  }

  Widget _officialText(String? value) {
    if (value == null || value.isEmpty) {
      return const PendingNotice();
    }
    return _bodyText(value);
  }

  Widget _bodyText(String value) {
    return Text(value, style: AppType.body);
  }

  Widget _ingredients(DrugBasics basics) {
    if (basics.ingredients.isEmpty) return const SizedBox.shrink();
    return _fact(
      '성분',
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final ingredient in basics.ingredients)
            Text(ingredient, textAlign: TextAlign.right, style: AppType.body),
        ],
      ),
    );
  }

  Widget _info(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return _fact(
      label,
      Text(value, textAlign: TextAlign.right, style: AppType.body),
    );
  }

  Widget _fact(String label, Widget value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 84, child: Text(label, style: AppType.caption)),
          const SizedBox(width: 12),
          Expanded(child: value),
        ],
      ),
    );
  }
}
