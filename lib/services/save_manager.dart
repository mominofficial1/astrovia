import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/save_data.dart';

class SaveManager {
  static final SaveManager instance = SaveManager._internal();
  SaveManager._internal();

  AstraviaSaveData? _cachedData;
  File? _saveFile;

  AstraviaSaveData get data {
    _cachedData ??= AstraviaSaveData();
    return _cachedData!;
  }

  Future<void> init() async {
    try {
      if (!kIsWeb) {
        String basePath = "";
        if (Platform.isWindows) {
          final appData = Platform.environment['APPDATA'];
          if (appData != null && Directory(appData).existsSync()) {
            final dir = Directory('$appData/AstraviaGame');
            if (!dir.existsSync()) dir.createSync(recursive: true);
            basePath = dir.path;
          }
        }
        if (basePath.isEmpty) {
          basePath = Directory.current.path;
        }
        _saveFile = File('$basePath/astravia_save_v2.json');

        if (_saveFile != null && _saveFile!.existsSync()) {
          final raw = await _saveFile!.readAsString();
          final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
          _cachedData = AstraviaSaveData.fromJson(jsonMap);
          if (kDebugMode) {
            print("Astravia Save loaded successfully from ${_saveFile!.path}");
          }
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("SaveManager load error, initializing default: $e");
      }
    }
    _cachedData = AstraviaSaveData();
  }

  Future<void> save() async {
    if (_cachedData == null) return;
    try {
      if (!kIsWeb && _saveFile != null) {
        final jsonStr = jsonEncode(_cachedData!.toJson());
        await _saveFile!.writeAsString(jsonStr, flush: true);
        if (kDebugMode) {
          print("Astravia Save written successfully to ${_saveFile!.path}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("SaveManager write error: $e");
      }
    }
  }

  Future<void> resetSave() async {
    _cachedData = AstraviaSaveData();
    await save();
  }
}
