import 'package:flutter_test/flutter_test.dart';
import 'package:pill_app/main.dart';

void main() {
  testWidgets('앱이 홈 화면을 표시한다', (WidgetTester tester) async {
    await tester.pumpWidget(const PillApp());
    expect(find.text('DailyPills'), findsOneWidget);
    expect(find.text('약 사진으로 찾기'), findsOneWidget);
    expect(find.text('오늘의 복약'), findsOneWidget);
  });
}
