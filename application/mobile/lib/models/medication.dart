import 'drug.dart';

class Medication {
  const Medication({
    required this.id,
    required this.kCode,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.memo,
    required this.times,
    required this.drug,
  });

  final int id;
  final String kCode;
  final String name;
  final String startDate;
  final String? endDate;
  final String? memo;
  final List<String> times;
  final DrugInfo? drug;

  factory Medication.fromJson(Map<String, dynamic> json) {
    final drug = json['drug'];
    return Medication(
      id: (json['id'] as num).toInt(),
      kCode: json['k_code'] as String,
      name: json['name'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      memo: json['memo'] as String?,
      times: (json['times'] as List).map((item) => item.toString()).toList(),
      drug: drug is Map<String, dynamic> ? DrugInfo.fromJson(drug) : null,
    );
  }
}

class Dose {
  const Dose({
    required this.medicationId,
    required this.kCode,
    required this.name,
    required this.date,
    required this.scheduledTime,
    required this.taken,
    required this.takenAt,
  });

  final int medicationId;
  final String kCode;
  final String name;
  final String date;
  final String scheduledTime;
  final bool taken;
  final String? takenAt;

  factory Dose.fromJson(Map<String, dynamic> json) {
    return Dose(
      medicationId: (json['medication_id'] as num).toInt(),
      kCode: json['k_code'] as String,
      name: json['name'] as String,
      date: json['date'] as String,
      scheduledTime: json['scheduled_time'] as String,
      taken: json['taken'] == true,
      takenAt: json['taken_at'] as String?,
    );
  }
}

class ScheduleDay {
  const ScheduleDay({required this.date, required this.items});

  final String date;
  final List<Dose> items;

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    return ScheduleDay(
      date: json['date'] as String,
      items: raw is List
          ? raw.whereType<Map<String, dynamic>>().map(Dose.fromJson).toList()
          : const [],
    );
  }
}
