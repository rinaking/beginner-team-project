import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/root_screen.dart';
import 'services/api_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PillApp());
}

class PillApp extends StatelessWidget {
  const PillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(ApiService())..loadMeta(),
      child: MaterialApp(
        title: 'DailyPills',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('ko'),
        supportedLocales: const [Locale('ko')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const RootScreen(),
      ),
    );
  }
}
