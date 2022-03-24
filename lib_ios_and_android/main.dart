import 'dart:async';
import 'package:body_weight_tracker/providers/body_weight_tracker_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'body_weight_tracker_screen/body_weight_tracker_screen.dart';
import 'constants/strings.dart';
import 'constants/color_palette.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    BodyWeightTrackerApp(),
  );
}

class BodyWeightTrackerApp extends StatelessWidget {
  static const String fontFamily = "Avro";
  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      //Keyboard dismisses on tap anywhere in app.
      child: PlatformApp(
        cupertino: (_, __) => CupertinoAppData(
          theme: CupertinoThemeData(
            primaryColor: ColorPalette.primaryColor,
            primaryContrastingColor: Colors.black,
            barBackgroundColor: ColorPalette.darkPrimaryColor,
            scaffoldBackgroundColor: ColorPalette.backGroundColor,
            textTheme: CupertinoTextThemeData(
              navActionTextStyle: TextStyle(
                  fontFamily: fontFamily,
                  color: ColorPalette.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              textStyle: TextStyle(
                  fontFamily: fontFamily, color: ColorPalette.primaryTextColor),
              navTitleTextStyle: TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.bold,
                color: ColorPalette.secondaryTextColor,
              ),
              primaryColor: ColorPalette.primaryTextColor,
              actionTextStyle: TextStyle(
                fontFamily: fontFamily,
                color: ColorPalette.primaryTextColor,
              ),
            ),
          ),
        ),
        material: (_, __) => MaterialAppData(
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
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            dialogTheme: DialogTheme(
              backgroundColor: ColorPalette.backGroundColor,
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
            fontFamily: fontFamily,
            scaffoldBackgroundColor: ColorPalette.backGroundColor,
          ),
        ),
        title: Strings.bodyWeightTrackerTitle,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [
          const Locale('en'),
        ],
        home: ChangeNotifierProvider<BodyWeightTrackerProvider>(
          create: (context) => BodyWeightTrackerProvider(),
          child: BodyWeightTrackerScreen(),
        ),
      ),
    );
  }
}
