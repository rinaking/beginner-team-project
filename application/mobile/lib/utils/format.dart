String toIsoDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime parseIsoDate(String value) {
  final parts = value.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

String formatDotDate(String iso) {
  final parts = iso.split('-');
  if (parts.length != 3) return iso;
  return '${parts[0]}.${parts[1]}.${parts[2]}';
}

String formatKoreanDate(DateTime date) {
  const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
  return '${date.month}월 ${date.day}일 ${weekdays[date.weekday - 1]}';
}

String formatMonthDay(String iso) {
  final date = parseIsoDate(iso);
  return '${date.month}월 ${date.day}일';
}

String formatClock(String isoDateTime) {
  final parsed = DateTime.parse(isoDateTime).toLocal();
  final hour = parsed.hour.toString().padLeft(2, '0');
  final minute = parsed.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String formatConfidence(double confidence) {
  return 'AI 인식 신뢰도 ${(confidence * 100).toStringAsFixed(1)}%';
}
