import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../l10n/app_localizations.dart';
import '../blocking/blocking.dart';
import '../calendar/calendar.dart';
import '../home/home.dart';
import '../setting/setting.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const BlockingScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFFFFAF0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.black,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/image/home.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/image/home.svg',
                  width: 28,
                  height: 28,
                  colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcIn),
                ),
                label: t.navHome,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/image/calendar.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/image/calendar.svg',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(Colors.orange, BlendMode.srcIn),
                ),
                label: t.navCalendar,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/image/block.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/image/block.svg',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(Colors.orange, BlendMode.srcIn),
                ),
                label: t.navBlock,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/image/setting.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/image/setting.svg',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(Colors.orange, BlendMode.srcIn),
                ),
                label: t.navSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
