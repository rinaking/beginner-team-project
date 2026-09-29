import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pill_app/screens/drug_detail_screen.dart';
import 'package:pill_app/services/api_service.dart';
import 'package:pill_app/state/app_state.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('e약은요와 DUR이 모두 있으면 공식 본문과 기본정보를 보여 준다', (tester) async {
    await _open(
      tester,
      _detail(
        kCode: 'K-000573',
        name: '게보린정 300mg/PTP',
        etcOtc: '일반의약품',
        material: '아세트아미노펜|카페인무수물',
        company: '삼진제약(주)',
        classNo: '[01140]해열.진통.소염제',
        chart: '흰색의 정제',
        storage: '습기를 피해 보관합니다.',
        efficacy: '두통에 사용합니다.',
        dosage: '성인 1회 1정',
        caution: '과다 복용하지 않습니다.',
        beforeUse: '알레르기가 있으면 전문가와 상의합니다.',
      ),
    );

    expect(find.text('게보린정 300mg/PTP'), findsOneWidget);
    expect(find.text('일반의약품'), findsOneWidget);
    expect(find.text('아세트아미노펜'), findsOneWidget);
    expect(find.text('삼진제약(주)'), findsOneWidget);
    expect(find.text('두통에 사용합니다.'), findsOneWidget);
    expect(find.text('성인 1회 1정'), findsOneWidget);
    expect(find.text('과다 복용하지 않습니다.'), findsOneWidget);
    expect(find.text('알레르기가 있으면 전문가와 상의합니다.'), findsOneWidget);
    expect(find.text('습기를 피해 보관합니다.'), findsOneWidget);
    expect(find.text('정보 업데이트 예정'), findsNothing);
    expect(find.text('내 복용약에 추가'), findsOneWidget);
  });

  testWidgets('e약은요만 있으면 본문을 보여주고 없는 DUR 보관방법은 숨긴다', (tester) async {
    await _open(
      tester,
      _detail(
        kCode: 'K-000250',
        name: '마그밀정(수산화마그네슘)',
        etcOtc: '일반의약품',
        material: '수산화마그네슘',
        company: '삼남제약(주)',
        classNo: '[02340]제산제',
        chart: '흰색의 정제',
        efficacy: '위산 과다에 사용합니다.',
        dosage: '성인 1회 1정',
        caution: '신장 질환이 있으면 전문가와 상의합니다.',
      ),
    );

    expect(find.text('마그밀정(수산화마그네슘)'), findsOneWidget);
    expect(find.text('위산 과다에 사용합니다.'), findsOneWidget);
    expect(find.text('보관방법'), findsNothing);
    expect(find.text('정보 업데이트 예정'), findsNothing);
  });

  testWidgets('DUR만 있으면 기본정보를 보완하고 본문은 업데이트 예정이다', (tester) async {
    await _open(
      tester,
      _detail(
        kCode: 'K-016232',
        name: '리피토정 20mg',
        etcOtc: '전문의약품',
        material: '아토르바스타틴칼슘삼수화물',
        company: '한국화이자제약(주)',
        classNo: '[02180]동맥경화용제',
        chart: '흰색의 타원형 필름코팅정',
        storage: '기밀용기, 실온보관',
        validTerm: '제조일로부터 36개월',
      ),
    );

    expect(find.text('리피토정 20mg'), findsOneWidget);
    expect(find.text('전문의약품'), findsOneWidget);
    expect(find.text('한국화이자제약(주)'), findsOneWidget);
    expect(find.text('기밀용기, 실온보관'), findsOneWidget);
    expect(find.text('제조일로부터 36개월'), findsOneWidget);
    expect(find.text('정보 업데이트 예정'), findsNWidgets(3));
    expect(find.text('임부금기'), findsNothing);
    expect(find.text('용량주의'), findsNothing);
  });

  testWidgets('공식 데이터가 없어도 기본정보 화면은 열린다', (tester) async {
    await _open(
      tester,
      _detail(
        kCode: 'K-004378',
        name: '타이레놀정500mg',
        etcOtc: '일반의약품',
        material: '아세트아미노펜',
        company: '(주)한국얀센',
        classNo: '[01140]해열.진통.소염제',
        chart: '흰색의 장방형 필름코팅정제',
      ),
    );

    expect(find.text('타이레놀정500mg'), findsOneWidget);
    expect(find.text('아세트아미노펜'), findsOneWidget);
    expect(find.text('(주)한국얀센'), findsOneWidget);
    expect(find.text('[01140]해열.진통.소염제'), findsOneWidget);
    expect(find.text('흰색의 장방형 필름코팅정제'), findsOneWidget);
    expect(find.text('정보 업데이트 예정'), findsNWidgets(3));
    expect(find.text('보관방법'), findsNothing);
    expect(find.text('내 복용약에 추가'), findsOneWidget);
  });
}

Future<void> _open(WidgetTester tester, Map<String, dynamic> detail) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AppState(
        ApiService(client: _FakeClient(detail), baseUrl: 'http://example.test'),
      ),
      child: MaterialApp(
        home: DrugDetailScreen(kCode: detail['k_code'] as String),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Map<String, dynamic> _detail({
  required String kCode,
  required String name,
  String? etcOtc,
  String? material,
  String? company,
  String? classNo,
  String? chart,
  String? storage,
  String? validTerm,
  String? efficacy,
  String? dosage,
  String? caution,
  String? beforeUse,
  String? sideEffect,
  String? interactionNote,
}) {
  return {
    'k_code': kCode,
    'drug': {'name': name},
    'basics': {
      'etc_otc': etcOtc,
      'material': material,
      'company': company,
      'class_no': classNo,
      'chart': chart,
      'storage_method': storage,
      'valid_term': validTerm,
    },
    'official': {
      'efficacy': efficacy,
      'dosage': dosage,
      'caution': caution,
      'before_use': beforeUse,
      'side_effect': sideEffect,
      'interaction_note': interactionNote,
    },
  };
}

class _FakeClient extends http.BaseClient {
  _FakeClient(this.detail);

  final Map<String, dynamic> detail;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;
    final Object payload;
    if (path.endsWith('/medications')) {
      payload = <Object>[];
    } else if (path.endsWith('/interactions/check')) {
      payload = {
        'data_available': false,
        'message': '확인된 상호작용 정보가 없습니다. 안전 여부를 판단한 결과는 아닙니다.',
        'interactions': <Object>[],
      };
    } else {
      payload = detail;
    }
    final bytes = utf8.encode(jsonEncode(payload));
    return http.StreamedResponse(Stream<List<int>>.value(bytes), 200);
  }
}
