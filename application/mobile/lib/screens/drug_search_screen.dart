import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/drug.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'add_medication_screen.dart';

class DrugSearchScreen extends StatefulWidget {
  const DrugSearchScreen({super.key});

  @override
  State<DrugSearchScreen> createState() => _DrugSearchScreenState();
}

class _DrugSearchScreenState extends State<DrugSearchScreen> {
  final TextEditingController _query = TextEditingController();
  Timer? _debounce;
  List<DrugDetail> _results = const [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _search(value));
  }

  Future<void> _search(String value) async {
    final keyword = value.trim();
    if (keyword.isEmpty) {
      setState(() {
        _results = const [];
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await context.read<AppState>().api.searchDrugs(keyword);
      if (!mounted || _query.text.trim() != keyword) return;
      setState(() => _results = results);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(DrugDetail drug) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicationScreen(
          kCode: drug.kCode,
          name: drug.drug.name,
        ),
      ),
    );
    if (saved == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('약 검색')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.page, 8, AppSpace.page, 28),
        children: [
          TextField(
            controller: _query,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '약 이름을 입력하세요',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _onChanged,
          ),
          const SizedBox(height: 8),
          const Text(
            '현재 모델이 지원하는 약만 검색됩니다.',
            style: TextStyle(color: AppColors.navySoft, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            EmptyHint(icon: Icons.cloud_off_outlined, message: _error!)
          else if (_query.text.trim().isEmpty)
            const EmptyHint(
              icon: Icons.search,
              message: '약 이름을 입력하면 학습된 의약품에서 찾습니다.',
            )
          else if (_results.isEmpty)
            const EmptyHint(
              icon: Icons.search_off_outlined,
              message: '일치하는 약이 없습니다.',
            )
          else
            for (final drug in _results)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => _open(drug),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drug.drug.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      if (drug.drug.company != null && drug.drug.company!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        MutedText(drug.drug.company!, size: 13),
                      ],
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
