import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'resolution_simulator.dart';

/// Persists overlay QA preferences between sessions.
class QualificationSettingsStore {
  static const viewportKey = 'dpad_qualification.viewport';
  static const bezelKey = 'dpad_qualification.show_bezel';
  static const networkKey = 'dpad_qualification.network_profile';
  static const defectDraftKey = 'dpad_qualification.defect_draft';

  Future<QualificationSettings?> load({
    required List<CustomSimulatedDevice> customDevices,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final viewportStorageKey = prefs.getString(viewportKey);
    if (viewportStorageKey == null && !prefs.containsKey(bezelKey)) {
      return null;
    }

    SimulatedViewport viewport = SimulatedViewport.preset(
      SimulatedDevice.native,
    );
    if (viewportStorageKey != null) {
      viewport =
          SimulatedViewport.fromStorageKey(
            viewportStorageKey,
            customDevices: customDevices,
          ) ??
          viewport;
    }

    DefectDraft? defectDraft;
    final draftJson = prefs.getString(defectDraftKey);
    if (draftJson != null) {
      try {
        final map = jsonDecode(draftJson) as Map<String, dynamic>;
        defectDraft = DefectDraft.fromMap(map);
      } catch (_) {
        defectDraft = null;
      }
    }

    return QualificationSettings(
      viewport: viewport,
      showBezel: prefs.getBool(bezelKey) ?? true,
      networkProfile: prefs.getString(networkKey) ?? 'Excellent WiFi',
      defectDraft: defectDraft,
    );
  }

  Future<void> save({
    required SimulatedViewport viewport,
    required bool showBezel,
    required String networkProfile,
    DefectDraft? defectDraft,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(viewportKey, viewport.storageKey);
    await prefs.setBool(bezelKey, showBezel);
    await prefs.setString(networkKey, networkProfile);
    if (defectDraft == null ||
        (defectDraft.title.isEmpty && defectDraft.description.isEmpty)) {
      await prefs.remove(defectDraftKey);
    } else {
      await prefs.setString(defectDraftKey, jsonEncode(defectDraft.toMap()));
    }
  }
}

class QualificationSettings {
  const QualificationSettings({
    required this.viewport,
    required this.showBezel,
    required this.networkProfile,
    this.defectDraft,
  });

  final SimulatedViewport viewport;
  final bool showBezel;
  final String networkProfile;
  final DefectDraft? defectDraft;
}

class DefectDraft {
  const DefectDraft({
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
  });

  final String title;
  final String description;
  final String severity;
  final String category;

  factory DefectDraft.fromMap(Map<String, dynamic> map) {
    return DefectDraft(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      severity: map['severity'] as String? ?? 'P2',
      category: map['category'] as String? ?? 'UI / Spacing',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'severity': severity,
      'category': category,
    };
  }
}
