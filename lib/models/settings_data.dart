import 'package:flutter/material.dart';

class SettingsData { 

  final String themeMode;

  final String instrumentType;

  final String countInEffect;

  final Locale sessionLocale;

  const SettingsData({
    required this.themeMode,
    required this.instrumentType,
    required this.countInEffect,
    required this.sessionLocale
  });

  static SettingsData fromJson(Map<String, dynamic> json) => SettingsData(
    themeMode: json['themeMode'] ?? 'LIGHT',
    instrumentType: json['instrumentType'] ?? '',
    countInEffect: json['countInEffect'] ?? '',
    sessionLocale: json['sessionLocale'] != null ? Locale(json['sessionLocale']) : Locale('en')
  );

  @override
  Map<String, dynamic> toJson() => {
    'themeMode': themeMode,
    'instrumentType': instrumentType,
    'countInEffect': countInEffect,
    'sessionLocale': sessionLocale.languageCode,
  };

  static SettingsData empty() {
    return SettingsData(themeMode: 'DARK', instrumentType: 'GUITAR', countInEffect: 'FINGERCLICK', sessionLocale: Locale('en'));
  }
}