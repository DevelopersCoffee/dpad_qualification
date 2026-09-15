# D-Pad Qualification (`dpad_qualification`)

[![pub package](https://img.shields.io/pub/v/dpad_qualification.svg)](https://pub.dev/packages/dpad_qualification)
[![CI](https://github.com/DevelopersCoffee/dpad_qualification/actions/workflows/ci.yml/badge.svg)](https://github.com/DevelopersCoffee/dpad_qualification/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive device qualification, resolution simulation, and D-Pad remote control emulation harness for Flutter applications across Android TV, Fire TV, tablets, foldables, and desktop form factors.

---

## Features

* **Resolution Simulator (`ResolutionSimulator`)**: Scale and constrain layout viewports to simulate **Google TV 4K**, **Shield TV**, **Fire TV Stick**, **Tablet Landscape**, **Foldable**, and **Mobile** viewports directly on your development desktop or web browser.
* **On-Screen D-Pad Remote (`DpadRemoteController`)**: Emulate directional remote control navigation (`ArrowUp`, `ArrowDown`, `ArrowLeft`, `ArrowRight`, `Select/OK`, `Back/Escape`, `Home`, `Play/Pause`) sending native `HardwareKeyboard` events.
* **Interactive Testing Overlay (`DeviceQualificationOverlay`)**: Floating QA panel with live FPS telemetry, frame drop tracking, network context labels, settings persistence, screenshot export, GitHub issue URL copy, and Markdown defect reports.
* **Headless Report Generator (`DeviceQualificationReportBuilder`)**: Structured qualification evidence for CI/CD matrices or hardware release sign-offs, with JSON/Markdown file export helpers.
* **Custom Device Presets (`CustomSimulatedDevice`)**: Add your own viewport sizes alongside the built-in TV, tablet, and mobile presets.

---

## Getting Started

Add `dpad_qualification` to your `pubspec.yaml`:

```yaml
dependencies:
  dpad_qualification: ^1.1.0
```

---

## Usage

### 1. Wrap Your App with `DeviceQualificationOverlay`

Wrap your top-level widget (e.g. inside `MaterialApp.builder` or root widget) to enable interactive device simulation during development or QA builds:

```dart
import 'package:flutter/material.dart';
import 'package:dpad_qualification/dpad_qualification.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TV Demo',
      theme: ThemeData.dark(),
      builder: (context, child) {
        return DeviceQualificationOverlay(
          // Optional: notify your app when the simulated form factor changes.
          onFormFactorOverride: (formFactor, tvPlatform) {
            debugPrint('Form factor: $formFactor, TV: $tvPlatform');
          },
          // Optional: react to network context label changes in your HTTP stack.
          networkQualificationHook: (profile, latencyMs) {
            debugPrint('Network context: $profile ($latencyMs ms reference)');
          },
          // Optional: save QA screenshots during manual testing.
          screenshotDirectory: '/tmp/dpad-qa-screenshots',
          // Optional: custom presets such as Apple TV or Roku.
          customDevices: const [
            CustomSimulatedDevice(
              name: 'Apple TV 4K',
              width: 3840,
              height: 2160,
              isTv: true,
            ),
          ],
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomeScreen(),
    );
  }
}
```

### 2. Standalone Resolution Simulator (`ResolutionSimulator`)

Simulate specific TV or mobile resolutions anywhere in your widget tree:

```dart
import 'package:flutter/material.dart';
import 'package:dpad_qualification/dpad_qualification.dart';

Widget buildTvPreview(Widget appChild) {
  return const ResolutionSimulator(
    device: SimulatedDevice.androidTv1080p,
    showBezel: true,
    child: appChild,
  );
}
```

### 3. D-Pad Remote Overlay (`DpadRemoteController`)

Add an interactive D-pad remote control overlay anywhere on screen:

```dart
import 'package:flutter/material.dart';
import 'package:dpad_qualification/dpad_qualification.dart';

Widget buildRemoteController() {
  return DpadRemoteController(
    onBackPress: () {
      print('Remote overlay closed');
    },
  );
}
```

### 4. Headless Qualification Report (`DeviceQualificationReportBuilder`)

Generate structured evidence for CI matrices or release sign-offs:

```dart
import 'package:dpad_qualification/qualification_reports.dart';

void main() async {
  const builder = DeviceQualificationReportBuilder();
  final report = builder.build(
    reportId: 'rpt_001',
    campaignId: 'cmp_release_2026_09',
    deviceName: 'Shield TV 4K',
    appProfile: 'production',
    phaseStatuses: {
      'phase1_splash': DeviceQualificationPhaseStatus.passed,
      'phase3_dpad_focus': DeviceQualificationPhaseStatus.passed,
    },
  );

  print(report.toMarkdown());

  final files = await writeQualificationReportFiles(
    report: report,
    directoryPath: './build/qualification',
    baseName: 'shield-tv-signoff',
  );
  print('Wrote ${files.jsonPath} and ${files.markdownPath}');
}
```

Reports-only import path: `package:dpad_qualification/qualification_reports.dart`

---

## Supported Simulated Devices

| Device | Resolution | Aspect Ratio | Navigation Mode |
| :--- | :--- | :--- | :--- |
| **Native (Full Screen)** | Unconstrained | Dynamic | Traditional |
| **Mobile Browser Fallback** | 390 × 844 | ~9:19 | Traditional |
| **Android TV Compact Browser** | 1024 × 576 | 16:9 | Directional (D-Pad) |
| **Android TV 720p** | 1280 × 720 | 16:9 | Directional (D-Pad) |
| **Android TV 1080p** | 1920 × 1080 | 16:9 | Directional (D-Pad) |
| **Fire TV Stick** | 1920 × 1080 | 16:9 | Directional (D-Pad) |
| **Google TV 4K** | 3840 × 2160 | 16:9 | Directional (D-Pad) |
| **Shield TV 4K** | 3840 × 2160 | 16:9 | Directional (D-Pad) |
| **Tablet Landscape** | 1024 × 768 | 4:3 | Traditional |
| **Foldable Portrait** | 673 × 841 | ~4:5 | Traditional |
| **Foldable Landscape** | 841 × 673 | ~5:4 | Traditional |

Set `showBezel: false` on `ResolutionSimulator` to hide the device label and bezel chrome.

Network context labels in the overlay annotate defect reports with reference latency values. They do not throttle network traffic; wire your own HTTP client if you need real throttling.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
