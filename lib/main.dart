// lib/main.dart - تحديث لإضافة JourneyProvider
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'dart:async';

import 'app.dart';
import 'core/constants/app_colors.dart';
import 'core/localization/language_provider.dart';
import 'presentation/providers/paths_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/saved_paths_provider.dart';
import 'presentation/providers/journey_provider.dart'; // إضافة جديدة

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تم إزالة Paint.enableDithering لأنه غير مدعوم
  
  // معالجة أخطاء التطبيق
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  
  // تعيين معالج أخطاء غير متوقعة - أبسط نسخة
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warning_circle,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'حدث خطأ غير متوقع',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'يرجى المحاولة مرة أخرى أو إعادة تشغيل التطبيق',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.primary,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PathsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SavedPathsProvider()),
        ChangeNotifierProvider(create: (_) => JourneyProvider()), // إضافة جديدة
      ],
      child: const VeloraApp(),
    ),
  );
}