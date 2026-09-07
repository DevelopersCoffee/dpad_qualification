# D-Pad Qualification (`dpad_qualification`)

[![pub package](https://img.shields.io/pub/v/dpad_qualification.svg)](https://pub.dev/packages/dpad_qualification)
[![CI](https://github.com/DevelopersCoffee/dpad_qualification/actions/workflows/ci.yml/badge.svg)](https://github.com/DevelopersCoffee/dpad_qualification/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive device qualification, resolution simulation, and D-Pad remote control emulation harness for Flutter applications across Android TV, Fire TV, tablets, foldables, and desktop form factors.

---

## Features

* **Resolution Simulator (`ResolutionSimulator`)**: Scale and constrain layout viewports to simulate **Google TV 4K**, **Shield TV**, **Fire TV Stick**, **Tablet Landscape**, **Foldable**, and **Mobile** viewports directly on your development desktop or web browser.
* **On-Screen D-Pad Remote (`DpadRemoteController`)**: Emulate directional remote control navigation (`ArrowUp`, `ArrowDown`, `ArrowLeft`, `ArrowRight`, `Select/OK`, `Back/Escape`, `Home`, `Play/Pause`) sending native `HardwareKeyboard` events.
* **Interactive Testing Overlay (`DeviceQualificationOverlay`)**: Floating QA panel providing live FPS telemetry, frame drop tracking, network latency simulation profiles, and Markdown defect report export to clipboard.
* **Headless Report Generator (`DeviceQualificationReportBuilder`)**: Generate structured qualification evidence reports for CI/CD matrices or hardware release sign-offs.

---

## Getting Started

Add `dpad_qualification` to your `pubspec.yaml`:

```yaml
dependencies:
  dpad_qualification: ^1.0.0
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

---

## Supported Simulated Devices

| Device | Resolution | Aspect Ratio | Navigation Mode |
| :--- | :--- | :--- | :--- |
| **Native (Full Screen)** | Unconstrained | Dynamic | Traditional |
| **Android TV 720p** | 1280 × 720 | 16:9 | Directional (D-Pad) |
| **Android TV 1080p** | 1920 × 1080 | 16:9 | Directional (D-Pad) |
| **Fire TV Stick** | 1920 × 1080 | 16:9 | Directional (D-Pad) |
| **Google TV 4K** | 3840 × 2160 | 16:9 | Directional (D-Pad) |
| **Shield TV 4K** | 3840 × 2160 | 16:9 | Directional (D-Pad) |
| **Tablet Landscape** | 1024 × 768 | 4:3 | Traditional |
| **Foldable Landscape** | 841 × 673 | ~5:4 | Traditional |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
