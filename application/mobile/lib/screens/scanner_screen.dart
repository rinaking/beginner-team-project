import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'detection_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _bytes;
  String _filename = 'pill.jpg';
  bool _loading = false;
  int _analysisStep = 0;
  Timer? _analysisTimer;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1600,
      );
      if (!mounted || file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _filename = file.name;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '사진을 불러오지 못했습니다.');
    }
  }

  Future<void> _analyze() async {
    final bytes = _bytes;
    if (bytes == null) {
      setState(() => _error = '먼저 알약 사진을 선택해 주세요.');
      return;
    }
    setState(() {
      _loading = true;
      _analysisStep = 0;
      _error = null;
    });
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted || _analysisStep >= 2) {
        timer.cancel();
        return;
      }
      setState(() => _analysisStep += 1);
    });
    try {
      final result = await context.read<AppState>().api.predict(bytes, _filename);
      final decoded = await decodeImageFromList(bytes);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetectionResultScreen(
            bytes: bytes,
            imageWidth: decoded.width,
            imageHeight: decoded.height,
            result: result,
          ),
        ),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      _analysisTimer?.cancel();
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = context.watch<AppState>().supportedDrugCount;
    final scope = count == null
        ? '현재 학습된 의약품만 식별할 수 있습니다.'
        : '현재 학습된 $count개 의약품만 식별할 수 있습니다.';
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.page, 20, AppSpace.page, 28),
        children: [
          if (_loading)
            AnalysisStatus(activeStep: _analysisStep)
          else ...[
            const Text('약 사진으로\n의약품을 찾아보세요', style: AppType.hero),
            const SizedBox(height: 10),
            const Text('알약 모양과 색이 잘 보이도록 한 장 준비해 주세요.', style: AppType.caption),
            const SizedBox(height: 22),
            if (_bytes == null)
              const _CaptureStage()
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.memory(
                  _bytes!,
                  height: 320,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_camera_outlined,
                    label: '카메라로 촬영',
                    onPressed: () => _pick(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library_outlined,
                    label: '갤러리에서 선택',
                    onPressed: () => _pick(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _analyze,
              child: const Text('AI로 약 분석하기'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            Text(
              '선명하고 밝은 환경에서 촬영하면 인식 정확도가 높아집니다. $scope',
              style: AppType.caption,
            ),
            const SizedBox(height: 8),
            const DisclaimerText(),
          ],
        ],
      ),
    );
  }
}

class _CaptureStage extends StatelessWidget {
  const _CaptureStage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.stage,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera_outlined, color: AppColors.primary, size: 64),
          SizedBox(height: 18),
          Text('알약 사진을 추가해주세요', style: AppType.title),
          SizedBox(height: 8),
          Text(
            '알약 전체가 잘 보이고\n밝은 곳에서 촬영하는 것이 좋아요.',
            textAlign: TextAlign.center,
            style: AppType.caption,
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.navy),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
