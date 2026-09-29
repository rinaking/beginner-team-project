import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'medications_screen.dart';
import 'scanner_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  void _select(int index) {
    setState(() => _index = index);
    final store = context.read<AppState>();
    if (index == 0) {
      store.loadToday();
    } else if (index == 2) {
      store.loadMedications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onOpenScanner: () => _select(1)),
            const ScannerScreen(),
            const MedicationsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _TabBar(index: _index, onSelect: _select),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _items = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home, '홈'),
    (Icons.photo_camera_outlined, Icons.photo_camera, '약 찾기'),
    (Icons.medication_outlined, Icons.medication, '내 복용약'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var itemIndex = 0; itemIndex < _items.length; itemIndex++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelect(itemIndex),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                          decoration: BoxDecoration(
                            color: index == itemIndex ? AppColors.mintStrong : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            index == itemIndex ? _items[itemIndex].$2 : _items[itemIndex].$1,
                            size: 22,
                            color: index == itemIndex ? AppColors.primary : AppColors.muted,
                          ),
                        ),
                        Text(
                          _items[itemIndex].$3,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: index == itemIndex ? FontWeight.w700 : FontWeight.w500,
                            color: index == itemIndex ? AppColors.primaryDeep : AppColors.muted,
                          ),
                        ),
                      ],
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
