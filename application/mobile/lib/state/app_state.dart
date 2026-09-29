import 'package:flutter/foundation.dart';

import '../models/medication.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  AppState(this.api);

  final ApiService api;

  bool loadingToday = false;
  String? todayError;
  List<Dose> today = const [];
  String? todayDate;

  bool loadingMedications = false;
  String? medicationsError;
  List<Medication> medications = const [];

  int? supportedDrugCount;
  final Set<String> pendingDoseKeys = {};

  Future<void> loadMeta() async {
    try {
      supportedDrugCount = await api.supportedDrugCount();
      notifyListeners();
    } on ApiException {
      supportedDrugCount = null;
    }
  }

  Future<void> loadToday() async {
    loadingToday = true;
    todayError = null;
    notifyListeners();
    try {
      final schedule = await api.today();
      todayDate = schedule.date;
      today = schedule.items;
    } on ApiException catch (error) {
      todayError = error.message;
    } finally {
      loadingToday = false;
      notifyListeners();
    }
  }

  Future<void> loadMedications() async {
    loadingMedications = true;
    medicationsError = null;
    notifyListeners();
    try {
      medications = await api.medications();
    } on ApiException catch (error) {
      medicationsError = error.message;
    } finally {
      loadingMedications = false;
      notifyListeners();
    }
  }

  Future<String?> markTaken(Dose dose) {
    return _updateDose(dose, taken: true);
  }

  Future<String?> cancelTaken(Dose dose) {
    return _updateDose(dose, taken: false);
  }

  Future<String?> _updateDose(Dose dose, {required bool taken}) async {
    final key = '${dose.medicationId}-${dose.date}-${dose.scheduledTime}';
    if (pendingDoseKeys.contains(key)) return null;
    pendingDoseKeys.add(key);
    notifyListeners();
    try {
      final updated = taken
          ? await api.markTaken(
              medicationId: dose.medicationId,
              date: dose.date,
              scheduledTime: dose.scheduledTime,
            )
          : await api.cancelTaken(
              medicationId: dose.medicationId,
              date: dose.date,
              scheduledTime: dose.scheduledTime,
            );
      today = [
        for (final item in today)
          if (_sameDose(item, updated)) updated else item,
      ];
      return null;
    } on ApiException catch (error) {
      return error.message;
    } finally {
      pendingDoseKeys.remove(key);
      notifyListeners();
    }
  }

  bool _sameDose(Dose left, Dose right) {
    return left.medicationId == right.medicationId &&
        left.date == right.date &&
        left.scheduledTime == right.scheduledTime;
  }
}
