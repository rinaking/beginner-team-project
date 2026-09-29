class DrugInfo {
  const DrugInfo({
    required this.name,
    this.nameEn,
    this.material,
    this.materialEn,
    this.company,
    this.companyEn,
    this.etcOtc,
    this.chart,
    this.shape,
    this.form,
    this.printFront,
    this.printBack,
    this.color1,
    this.color2,
    this.imageUrl,
    this.classNo,
  });

  final String name;
  final String? nameEn;
  final String? material;
  final String? materialEn;
  final String? company;
  final String? companyEn;
  final String? etcOtc;
  final String? chart;
  final String? shape;
  final String? form;
  final String? printFront;
  final String? printBack;
  final String? color1;
  final String? color2;
  final String? imageUrl;
  final String? classNo;

  List<String> get ingredients {
    final raw = material;
    if (raw == null) return const [];
    return raw
        .split('|')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  factory DrugInfo.fromJson(Map<String, dynamic> json) {
    return DrugInfo(
      name: _text(json['name']) ?? '이름 정보 없음',
      nameEn: _text(json['name_en']),
      material: _text(json['material']),
      materialEn: _text(json['material_en']),
      company: _text(json['company']),
      companyEn: _text(json['company_en']),
      etcOtc: _text(json['etc_otc']),
      chart: _text(json['chart']),
      shape: _text(json['shape']),
      form: _text(json['form']),
      printFront: _text(json['print_front']),
      printBack: _text(json['print_back']),
      color1: _text(json['color1']),
      color2: _text(json['color2']),
      imageUrl: _text(json['image_url']),
      classNo: _text(json['class_no']),
    );
  }

  static String? _text(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return text;
  }
}

class DrugBasics {
  const DrugBasics({
    this.etcOtc,
    this.material,
    this.company,
    this.classNo,
    this.chart,
    this.storageMethod,
    this.validTerm,
  });

  final String? etcOtc;
  final String? material;
  final String? company;
  final String? classNo;
  final String? chart;
  final String? storageMethod;
  final String? validTerm;

  List<String> get ingredients {
    final raw = material;
    if (raw == null) return const [];
    return raw
        .split('|')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  factory DrugBasics.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DrugBasics();
    return DrugBasics(
      etcOtc: DrugInfo._text(json['etc_otc']),
      material: DrugInfo._text(json['material']),
      company: DrugInfo._text(json['company']),
      classNo: DrugInfo._text(json['class_no']),
      chart: DrugInfo._text(json['chart']),
      storageMethod: DrugInfo._text(json['storage_method']),
      validTerm: DrugInfo._text(json['valid_term']),
    );
  }
}

class OfficialProfile {
  const OfficialProfile({
    this.efficacy,
    this.dosage,
    this.caution,
    this.beforeUse,
    this.sideEffect,
    this.interactionNote,
  });

  final String? efficacy;
  final String? dosage;
  final String? caution;
  final String? beforeUse;
  final String? sideEffect;
  final String? interactionNote;

  factory OfficialProfile.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OfficialProfile();
    return OfficialProfile(
      efficacy: DrugInfo._text(json['efficacy']),
      dosage: DrugInfo._text(json['dosage']),
      caution: DrugInfo._text(json['caution']),
      beforeUse: DrugInfo._text(json['before_use']),
      sideEffect: DrugInfo._text(json['side_effect']),
      interactionNote: DrugInfo._text(json['interaction_note']),
    );
  }
}

class DrugDetail {
  const DrugDetail({
    required this.kCode,
    required this.drug,
    this.basics = const DrugBasics(),
    required this.official,
  });

  final String kCode;
  final DrugInfo drug;
  final DrugBasics basics;
  final OfficialProfile official;

  factory DrugDetail.fromJson(Map<String, dynamic> json) {
    return DrugDetail(
      kCode: json['k_code'] as String,
      drug: DrugInfo.fromJson(json['drug'] as Map<String, dynamic>),
      basics: DrugBasics.fromJson(json['basics'] as Map<String, dynamic>?),
      official: OfficialProfile.fromJson(
        json['official'] as Map<String, dynamic>?,
      ),
    );
  }
}

class InteractionItem {
  const InteractionItem({
    required this.otherKCode,
    required this.otherName,
    required this.description,
    required this.withCurrentMedication,
  });

  final String otherKCode;
  final String otherName;
  final String description;
  final bool withCurrentMedication;

  factory InteractionItem.fromJson(Map<String, dynamic> json) {
    return InteractionItem(
      otherKCode: json['other_k_code'] as String? ?? '',
      otherName: json['other_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      withCurrentMedication: json['with_current_medication'] == true,
    );
  }
}

class InteractionResult {
  const InteractionResult({
    required this.dataAvailable,
    required this.message,
    required this.interactions,
  });

  final bool dataAvailable;
  final String? message;
  final List<InteractionItem> interactions;

  factory InteractionResult.fromJson(Map<String, dynamic> json) {
    final raw = json['interactions'];
    return InteractionResult(
      dataAvailable: json['data_available'] == true,
      message: json['message'] as String?,
      interactions: raw is List
          ? raw
              .whereType<Map<String, dynamic>>()
              .map(InteractionItem.fromJson)
              .toList()
          : const [],
    );
  }
}
