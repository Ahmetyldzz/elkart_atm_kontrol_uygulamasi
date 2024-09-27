// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:atm_kontrol_sistemi/constants/colors.dart';
import 'package:atm_kontrol_sistemi/constants/project_sizes.dart';
import 'package:atm_kontrol_sistemi/screens/homepage.dart';
import 'package:atm_kontrol_sistemi/screens/login_page.dart';
import 'package:atm_kontrol_sistemi/screens/web_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Servisi başlat
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(ProjectColors.darkTheme),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        BorderRadiusSizes.circleRadius))))),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(BorderRadiusSizes.highRadius)),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: ProjectColors.darkTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
