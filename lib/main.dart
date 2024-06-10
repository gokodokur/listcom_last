import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:listcom/bloc/language/language_cubit.dart';
import 'package:listcom/bloc/theme/theme_state.dart';
import 'package:listcom/bloc/user/user_state.dart';
import 'package:listcom/helper/notification_helper.dart';
import 'package:listcom/view/login_view.dart';
import 'package:listcom/view/shopping_lists_view.dart';
import 'package:listcom/bloc/theme/theme_cubit.dart';
import 'package:listcom/bloc/user/user_cubit.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'bloc/language/language_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.instance.init();
  tz.initializeTimeZones();

  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (context) => ThemeCubit()),
    BlocProvider(create: (context) => UserCubit()),
    BlocProvider(create: (context) => LanguageCubit()),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    BlocProvider.of<UserCubit>(context)
        .initStoredUser(); // Daha önce giriş yapılmış user varsa çek.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<UserCubit, UserState>(
          builder: (context, userState) {
            return BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, languageState) {
                return MaterialApp(
                  locale: languageState.locale, // Uygulamanın dili
                  supportedLocales:
                      AppLocalizations.supportedLocales, // Desteklenen diller
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  localeResolutionCallback:
                      (Locale? locale, Iterable<Locale> supportedLocales) {
                    /// [locale]: Cihazın dili null değilse
                    if (locale != null) {
                      debugPrint(
                          "Detected device language: Language Code: ${locale.languageCode}, Country Code: ${locale.countryCode}");

                      /// for döngüsü yardımıyla [supportedLocales] listesi içinde arama yapıyoruz
                      for (var supportedLocale in supportedLocales) {
                        /// Cihazın dil kodu [locale.languageCode] ve ülke kodu [locale.countryCode]
                        /// desteklenen diller arasındaki dil ve ülke kodlarının içinde [supportedLocale] var mı?
                        if (supportedLocale.languageCode ==
                                locale.languageCode &&
                            locale.countryCode == locale.countryCode) {
                          /// Varsa desteklenen dili döndür
                          return supportedLocale;
                        }
                      }
                    }
                    debugPrint("Language is not available.");

                    /// Yoksa [supportedLocales] Listesindeki ilk sonucu döndür.
                    return supportedLocales.first;
                  },
                  debugShowCheckedModeBanner: false,
                  title: 'Listcom',
                  theme: themeState.theme.lightTheme.copyWith(
                    textTheme: themeState.theme.lightTheme.textTheme.copyWith(
                      bodyMedium: TextStyle(
                        fontSize: themeState.fontSize.toDouble(),
                      ),
                      bodyLarge: TextStyle(
                          fontSize: themeState.fontSize.toDouble() + 2),
                    ),
                  ),
                  darkTheme: themeState.theme.darkTheme.copyWith(
                    textTheme: themeState.theme.darkTheme.textTheme.copyWith(
                      bodyMedium: TextStyle(
                        fontSize: themeState.fontSize.toDouble(),
                      ),
                      bodyLarge: TextStyle(
                          fontSize: themeState.fontSize.toDouble() + 2),
                    ),
                  ),
                  themeMode: themeState.themeMode,
                  home: userState.user == null
                      ? const LoginView()
                      : const ShoppingListsView(),
                );
              },
            );
          },
        );
      },
    );
  }
}
