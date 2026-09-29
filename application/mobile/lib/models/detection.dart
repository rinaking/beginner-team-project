import 'drug.dart';

class BoundingBox {
  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  final int x1;
  final int y1;
  final int x2;
  final int y2;

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: (json['x1'] as num).round(),
      y1: (json['y1'] as num).round(),
      x2: (json['x2'] as num).round(),
      y2: (json['y2'] as num).round(),
    );
  }
}

class Detection {
  const Detection({
    required this.classId,
    required this.confidence,
    required this.bbox,
    required this.kCode,
    required this.drug,
  });

  final int classId;
  final double confidence;
  final BoundingBox bbox;
  final String? kCode;
  final DrugInfo? drug;

  bool get canSave => kCode != null && drug != null;

  factory Detection.fromJson(Map<String, dynamic> json) {
    final drug = json['drug'];
    return Detection(
      classId: (json['class_id'] as num).toInt(),
      confidence: (json['confidence'] as num).toDouble(),
      bbox: BoundingBox.fromJson(json['bbox'] as Map<String, dynamic>),
      kCode: json['k_code'] as String?,
      drug: drug is Map<String, dynamic> ? DrugInfo.fromJson(drug) : null,
    );
  }
}

class PredictResult {
  const PredictResult({required this.detected, required this.detections});

  final bool detected;
  final List<Detection> detections;

  factory PredictResult.fromJson(Map<String, dynamic> json) {
    final raw = json['detections'];
    return PredictResult(
      detected: json['detected'] == true,
      detections: raw is List
          ? raw
              .whereType<Map<String, dynamic>>()
              .map(Detection.fromJson)
              .toList()
          : const [],
    );
  }
}
