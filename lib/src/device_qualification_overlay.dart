import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dpad_remote_controller.dart';
import 'github_issue_url.dart';
import 'network_qualification_hook.dart';
import 'qualification_settings.dart';
import 'resolution_simulator.dart';

typedef FormFactorOverrideCallback =
    void Function(String formFactor, String? tvPlatform);

/// An interactive overlay for Flutter app development and QA testing.
///
/// Features live resolution scaling, D-Pad remote control emulation,
/// FPS telemetry tracking, and defect report generation.
class DeviceQualificationOverlay extends StatefulWidget {
  final Widget child;
  final FormFactorOverrideCallback? onFormFactorOverride;
  final bool autoCycle;
  final List<CustomSimulatedDevice> customDevices;
  final NetworkQualificationHook? networkQualificationHook;
  final String issueTrackerUrl;
  final String? screenshotDirectory;
  final bool enabled;

  const DeviceQualificationOverlay({
    super.key,
    required this.child,
    this.onFormFactorOverride,
    this.autoCycle = false,
    this.customDevices = const [],
    this.networkQualificationHook,
    this.issueTrackerUrl =
        'https://github.com/DevelopersCoffee/dpad_qualification/issues',
    this.screenshotDirectory,
    this.enabled = kDebugMode,
  });

  @override
  State<DeviceQualificationOverlay> createState() =>
      _DeviceQualificationOverlayState();
}

class _DeviceQualificationOverlayState
    extends State<DeviceQualificationOverlay> {
  bool _showPanel = false;
  bool _showRemote = false;
  SimulatedViewport _viewport = SimulatedViewport.preset(
    SimulatedDevice.native,
  );
  String _networkProfile = 'Excellent WiFi';
  double _latencyMs = 0;
  bool _showBezel = true;
  final GlobalKey _captureKey = GlobalKey();

  // Diagnostic states
  double _fps = 60.0;
  int _droppedFrames = 0;
  Timer? _telemetryTimer;

  // Defect logging form states
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _severity = 'P2';
  String _category = 'UI / Spacing';

  final _settingsStore = QualificationSettingsStore();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startFpsTicker();
      _telemetryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _showPanel) {
          setState(() {});
        }
      });
      _loadPersistedSettings();
      if (widget.autoCycle) {
        _startAutoCycle();
      }
    }
  }

  Future<void> _loadPersistedSettings() async {
    final settings = await _settingsStore.load(
      customDevices: widget.customDevices,
    );
    if (!mounted || settings == null) return;
    setState(() {
      _viewport = settings.viewport;
      _showBezel = settings.showBezel;
      _networkProfile = settings.networkProfile;
      _latencyMs = _latencyForProfile(settings.networkProfile);
      _showRemote = settings.viewport.isTv;
      if (settings.defectDraft != null) {
        _titleController.text = settings.defectDraft!.title;
        _descriptionController.text = settings.defectDraft!.description;
        _severity = settings.defectDraft!.severity;
        _category = settings.defectDraft!.category;
      }
    });
    _updateFormFactorOverride(settings.viewport);
    widget.networkQualificationHook?.call(_networkProfile, _latencyMs);
  }

  List<SimulatedViewport> get _availableViewports => [
    for (final device in SimulatedDevice.values)
      SimulatedViewport.preset(device),
    for (final device in widget.customDevices) SimulatedViewport.custom(device),
  ];

  Future<void> _persistSettings() async {
    await _settingsStore.save(
      viewport: _viewport,
      showBezel: _showBezel,
      networkProfile: _networkProfile,
      defectDraft: DefectDraft(
        title: _titleController.text,
        description: _descriptionController.text,
        severity: _severity,
        category: _category,
      ),
    );
  }

  double _latencyForProfile(String profile) {
    return switch (profile) {
      'Excellent WiFi' => 10.0,
      '5 Mbps' => 45.0,
      '2 Mbps' => 120.0,
      '1 Mbps' => 250.0,
      'Offline' => double.infinity,
      _ => 0.0,
    };
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    _telemetryTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _startAutoCycle() {
    final viewports = _availableViewports;
    var index = 0;
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 8));
      if (!mounted) return false;
      index = (index + 1) % viewports.length;
      final nextViewport = viewports[index];
      setState(() {
        _viewport = nextViewport;
        _showRemote = nextViewport.isTv;
      });
      _updateFormFactorOverride(nextViewport);
      _persistSettings();
      return true;
    });
  }

  void _startFpsTicker() {
    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final durationMs = timing.totalSpan.inMicroseconds / 1000.0;
      if (durationMs > 0) {
        final instantFps = 1000.0 / durationMs;
        _fps = _fps * 0.95 + instantFps * 0.05;
        if (durationMs > 20.0) {
          _droppedFrames++;
        }
      }
    }
  }

  void _updateFormFactorOverride(SimulatedViewport viewport) {
    if (widget.onFormFactorOverride == null) return;
    if (viewport.isNative) {
      widget.onFormFactorOverride!('native', null);
      return;
    }
    if (viewport.isTv) {
      widget.onFormFactorOverride!('tv', 'android_tv');
    } else if (viewport.name.contains('Tablet')) {
      widget.onFormFactorOverride!('tablet', null);
    } else {
      widget.onFormFactorOverride!('mobile', null);
    }
  }

  String _defectMarkdown() {
    return '''
# [Device Defect Report] ${_titleController.text}

**Severity:** $_severity
**Category:** $_category
**Simulated Device Configuration:** ${_viewport.name} (${_viewport.width.toInt()}x${_viewport.height.toInt()})
**Network Context Label:** $_networkProfile (Reference latency: ${_latencyMs.isFinite ? '${_latencyMs.toInt()}ms' : 'offline'})
**Performance Telemetry:** ${_fps.toStringAsFixed(1)} FPS | $_droppedFrames Dropped Frames

## Description
${_descriptionController.text}

## QA Context
- **Timestamp:** ${DateTime.now().toLocal()}
- **Framework:** Flutter / D-Pad Qualification Harness
''';
  }

  void _copyDefectReport() {
    Clipboard.setData(ClipboardData(text: _defectMarkdown()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Defect report copied to clipboard in Markdown!'),
        backgroundColor: Colors.green,
      ),
    );
    _persistSettings();
  }

  Future<void> _openGitHubIssue() async {
    final url = buildGitHubIssueUrl(
      issueTrackerBase: widget.issueTrackerUrl,
      title: _titleController.text.isEmpty
          ? 'Device qualification defect'
          : _titleController.text,
      body: _defectMarkdown(),
    );
    await Clipboard.setData(ClipboardData(text: url.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('GitHub issue URL copied: $url'),
        backgroundColor: Colors.green,
      ),
    );
    _persistSettings();
  }

  Future<void> _captureScreenshot() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Screenshot export is not supported on web.'),
        ),
      );
      return;
    }

    final directoryPath = widget.screenshotDirectory;
    if (directoryPath == null || directoryPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Set screenshotDirectory on DeviceQualificationOverlay.',
          ),
        ),
      );
      return;
    }

    final boundary =
        _captureKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage();
    final byteData = await image.toByteData();
    if (byteData == null) return;

    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final safeName = _viewport.name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
    final file = File('${directory.path}/qa-$safeName-$timestamp.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Screenshot saved to ${file.path}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            key: _captureKey,
            child: ResolutionSimulator.viewport(
              viewport: _viewport,
              showBezel: _showBezel,
              child: widget.child,
            ),
          ),
        ),
        if (_showRemote && _viewport.isTv)
          Positioned(
            right: 20,
            bottom: 100,
            child: Draggable(
              feedback: DpadRemoteController(
                onBackPress: () => setState(() => _showRemote = false),
              ),
              childWhenDragging: const SizedBox.shrink(),
              child: DpadRemoteController(
                onBackPress: () => setState(() => _showRemote = false),
              ),
            ),
          ),
        Positioned(
          left: 12,
          bottom: 12,
          child: Opacity(
            opacity: _showPanel ? 0.3 : 0.9,
            child: GestureDetector(
              onTap: () => setState(() => _showPanel = !_showPanel),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bug_report, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'QA OVERLAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_showPanel)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 360,
            child: _buildQaPanel(),
          ),
      ],
    );
  }

  Widget _buildQaPanel() {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Container(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey[850]!, width: 2)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[900]!, Colors.black],
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Device Qualification Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => setState(() => _showPanel = false),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDiagnosticsCard(),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Simulated Layout'),
                    const SizedBox(height: 8),
                    _buildDeviceSelector(),
                    const SizedBox(height: 12),
                    _buildSwitchTile(
                      title: 'Show Screen Bezel',
                      value: _showBezel,
                      onChanged: (val) {
                        setState(() => _showBezel = val);
                        _persistSettings();
                      },
                    ),
                    if (_viewport.isTv) ...[
                      _buildSwitchTile(
                        title: 'Show Remote Controller Overlay',
                        value: _showRemote,
                        onChanged: (val) => setState(() => _showRemote = val),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildSectionHeader('Network Context Label'),
                    const SizedBox(height: 8),
                    _buildNetworkSelector(),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Log Defect (GitHub Report)'),
                    const SizedBox(height: 8),
                    _buildDefectForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TELEMETRY DATA',
            style: TextStyle(
              color: Colors.purpleAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(
                'FPS',
                '${_fps.toStringAsFixed(1)} FPS',
                _fps > 55 ? Colors.green : Colors.orange,
              ),
              _buildMetric(
                'Dropped Frames',
                '$_droppedFrames',
                _droppedFrames == 0 ? Colors.green : Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Active Resolution',
                  _viewport.isNative
                      ? 'Native'
                      : '${_viewport.width.toInt()}x${_viewport.height.toInt()}',
                  Colors.white70,
                ),
              ),
              Expanded(
                child: _buildMetric('Telemetry Status', 'active', Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _captureScreenshot,
                  icon: const Icon(Icons.photo_camera, size: 16),
                  label: const Text('Screenshot'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDeviceSelector() {
    final viewports = _availableViewports;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SimulatedViewport>(
          value: viewports.firstWhere(
            (viewport) => viewport.storageKey == _viewport.storageKey,
            orElse: () => _viewport,
          ),
          dropdownColor: Colors.grey[900],
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          items: viewports.map((viewport) {
            return DropdownMenuItem(
              value: viewport,
              child: Text(viewport.name),
            );
          }).toList(),
          onChanged: (viewport) {
            if (viewport == null) return;
            setState(() {
              _viewport = viewport;
              if (!viewport.isTv) _showRemote = false;
            });
            _updateFormFactorOverride(viewport);
            _persistSettings();
          },
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildNetworkSelector() {
    final profiles = [
      'Excellent WiFi',
      '5 Mbps',
      '2 Mbps',
      '1 Mbps',
      'Offline',
    ];
    return Column(
      children: profiles.map((p) {
        final isSelected = _networkProfile == p;
        return RadioListTile<String>(
          title: Text(
            p,
            style: TextStyle(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          value: p,
          // ignore: deprecated_member_use
          groupValue: _networkProfile,
          dense: true,
          contentPadding: EdgeInsets.zero,
          // ignore: deprecated_member_use
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _networkProfile = val;
                _latencyMs = _latencyForProfile(val);
              });
              widget.networkQualificationHook?.call(
                _networkProfile,
                _latencyMs,
              );
              _persistSettings();
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildDefectForm() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          onChanged: (_) => _persistSettings(),
          decoration: InputDecoration(
            labelText: 'Defect Summary / Title',
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Severity: ',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            DropdownButton<String>(
              value: _severity,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: ['P0', 'P1', 'P2', 'P3', 'P4'].map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (val) {
                setState(() => _severity = val ?? 'P2');
                _persistSettings();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Category: ',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            Expanded(
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white, fontSize: 13),
                items:
                    [
                      'UI / Spacing',
                      'Navigation / Focus',
                      'Streaming Quality',
                      'EPG Timeline',
                      'Search/Inputs',
                    ].map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                onChanged: (val) {
                  setState(() => _category = val ?? 'UI / Spacing');
                  _persistSettings();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          maxLines: 4,
          onChanged: (_) => _persistSettings(),
          decoration: InputDecoration(
            labelText: 'Defect Details / Steps to Reproduce',
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: _copyDefectReport,
            icon: const Icon(Icons.content_copy, size: 16, color: Colors.white),
            label: const Text('Export Report to Clipboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: _openGitHubIssue,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Copy GitHub Issue URL'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
