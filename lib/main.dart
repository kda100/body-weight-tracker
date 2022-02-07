import 'dart:async';
import 'package:body_weight_tracker/body_weight_tracker_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'body_weight_tracker_screen/body_weight_tracker_screen.dart';
import 'constants/strings.dart';
import 'constants/color_palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    MyPtApp(),
  );
}

class MyPtApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: MaterialApp(
        title: Strings.bodyWeightTrackerTitle,
        theme: ThemeData(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: ColorPalette.primaryColor,
                secondary: ColorPalette.accentColor,
                background: ColorPalette.backGroundColor),
            popupMenuTheme: PopupMenuThemeData(
              color: ColorPalette.backGroundColor,
              elevation: 5,
            ),
            primaryColor: ColorPalette.primaryColor,
            primaryColorDark: ColorPalette.darkPrimaryColor,
            primaryColorLight: ColorPalette.lightPrimaryColor,
            dividerColor: ColorPalette.borderColor,
            textTheme: TextTheme(
              headline1: TextStyle(
                  color: ColorPalette.primaryTextColor,
                  fontWeight: FontWeight.bold),
            ),
            dialogTheme: DialogTheme(
              backgroundColor: ColorPalette.backGroundColor,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(5),
                foregroundColor:
                    MaterialStateProperty.all(ColorPalette.primaryTextColor),
                backgroundColor:
                    MaterialStateProperty.all(ColorPalette.primaryColor),
                minimumSize: MaterialStateProperty.all(
                  Size(80, 40),
                ),
              ),
            ),
            backgroundColor: ColorPalette.backGroundColor,
            cardTheme: CardTheme(
              color: ColorPalette.backGroundColor,
              elevation: 10,
            ),
            progressIndicatorTheme: ProgressIndicatorThemeData(
              color: ColorPalette.primaryColor,
            ),
            appBarTheme: AppBarTheme(color: ColorPalette.darkPrimaryColor),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: ColorPalette.darkPrimaryColor),
            fontFamily: GoogleFonts.arvo().fontFamily,
            scaffoldBackgroundColor: ColorPalette.backGroundColor),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [
          const Locale('en'),
        ],
        home: Provider(
          create: (context) => BodyWeightTrackerProvider(),
          child: BodyWeightTrackerScreen(),
        ),
      ),
    );
  }
}
