import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'view_model/app_view_model.dart';
import 'view_model/home_view_model.dart';
import 'view_model/blocking_view_model.dart';
import 'theme/app_theme.dart';

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
            theme: appViewModel.themeStyle.theme(Brightness.light),
            darkTheme: appViewModel.themeStyle.theme(Brightness.dark),
            themeMode: appViewModel.themeMode,
            locale: appViewModel.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: AppRoutes.router,
          );
        },
      ),
    );
  }
}
