import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/l10n.dart';
import 'router/app_router.dart';
import 'view_model/app_view_model.dart';
import 'view_model/home_view_model.dart';
import 'view_model/blocking_view_model.dart';

class BrainrotApp extends StatelessWidget {
  const BrainrotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppViewModel()..loadSettings()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(
            create: (_) => BlockingViewModel()..initialize()),
      ],
      child: Consumer<AppViewModel>(
        builder: (context, appViewModel, child) {
          return MaterialApp.router(
            title: 'Brainrot',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFF27A3D),
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFFFF8EF),
              bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFF27A3D),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF171513),
              bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: Color(0xFF24211E),
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
              ),
            ),
            themeMode: appViewModel.themeMode,
            locale: appViewModel.locale,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
