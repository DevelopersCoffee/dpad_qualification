import 'package:flutter/material.dart';

/// Preset devices supported by [ResolutionSimulator].
enum SimulatedDevice {
  native(name: 'Native (Full Screen)', width: 0, height: 0, isTv: false),
  mobileBrowserPortrait(
    name: 'Mobile Browser Fallback',
    width: 390,
    height: 844,
    isTv: false,
  ),
  androidTvCompactBrowser(
    name: 'Android TV Compact Browser',
    width: 1024,
    height: 576,
    isTv: true,
  ),
  androidTv720p(name: 'Android TV 720p', width: 1280, height: 720, isTv: true),
  androidTv1080p(
    name: 'Android TV 1080p',
    width: 1920,
    height: 1080,
    isTv: true,
  ),
  fireTvStick(name: 'Fire TV Stick', width: 1920, height: 1080, isTv: true),
  googleTv4k(name: 'Google TV 4K', width: 3840, height: 2160, isTv: true),
  shieldTv4k(name: 'Shield TV 4K', width: 3840, height: 2160, isTv: true),
  tabletLandscape(
    name: 'Tablet Landscape (iPad)',
    width: 1024,
    height: 768,
    isTv: false,
  ),
  foldablePortrait(
    name: 'Foldable Portrait',
    width: 673,
    height: 841,
    isTv: false,
  ),
  foldableLandscape(
    name: 'Foldable Landscape',
    width: 841,
    height: 673,
    isTv: false,
  );

  const SimulatedDevice({
    required this.name,
    required this.width,
    required this.height,
    required this.isTv,
  });

  final String name;
  final double width;
  final double height;
  final bool isTv;

  bool get isNative => this == SimulatedDevice.native;
}

/// User-defined viewport preset for devices not covered by [SimulatedDevice].
class CustomSimulatedDevice {
  const CustomSimulatedDevice({
    required this.name,
    required this.width,
    required this.height,
    this.isTv = false,
  });

  final String name;
  final double width;
  final double height;
  final bool isTv;

  bool get isNative => false;
}

/// Unified viewport configuration for preset or custom devices.
class SimulatedViewport {
  const SimulatedViewport._({
    required this.name,
    required this.width,
    required this.height,
    required this.isTv,
    required this.storageKey,
  });

  final String name;
  final double width;
  final double height;
  final bool isTv;
  final String storageKey;

  bool get isNative => width == 0 && height == 0;

  factory SimulatedViewport.preset(SimulatedDevice device) {
    return SimulatedViewport._(
      name: device.name,
      width: device.width,
      height: device.height,
      isTv: device.isTv,
      storageKey: 'preset:${device.name}',
    );
  }

  factory SimulatedViewport.custom(CustomSimulatedDevice device) {
    return SimulatedViewport._(
      name: device.name,
      width: device.width,
      height: device.height,
      isTv: device.isTv,
      storageKey: 'custom:${device.name}',
    );
  }

  static SimulatedViewport? fromStorageKey(
    String key, {
    required Iterable<CustomSimulatedDevice> customDevices,
  }) {
    if (key.startsWith('preset:')) {
      final name = key.substring('preset:'.length);
      for (final device in SimulatedDevice.values) {
        if (device.name == name) {
          return SimulatedViewport.preset(device);
        }
      }
      return null;
    }
    if (key.startsWith('custom:')) {
      final name = key.substring('custom:'.length);
      for (final device in customDevices) {
        if (device.name == name) {
          return SimulatedViewport.custom(device);
        }
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SimulatedViewport && other.storageKey == storageKey;
  }

  @override
  int get hashCode => storageKey.hashCode;
}

/// A widget that constrains and scales its [child] to simulate specific device
/// screen resolutions and D-Pad navigation modes.
class ResolutionSimulator extends StatelessWidget {
  const ResolutionSimulator({
    required this.child,
    required this.device,
    this.showBezel = true,
    super.key,
  }) : viewport = null;

  const ResolutionSimulator.viewport({
    required this.child,
    required this.viewport,
    this.showBezel = true,
    super.key,
  }) : device = null;

  final Widget child;
  final SimulatedDevice? device;
  final SimulatedViewport? viewport;
  final bool showBezel;

  SimulatedViewport get _viewport =>
      viewport ?? SimulatedViewport.preset(device!);

  @override
  Widget build(BuildContext context) {
    final config = _viewport;
    if (config.isNative) {
      return child;
    }

    final simulatedSize = Size(config.width, config.height);

    return LayoutBuilder(
      builder: (context, constraints) {
        final parentSize = constraints.biggest;

        final parentAspect = parentSize.width / parentSize.height;
        final targetAspect = simulatedSize.width / simulatedSize.height;

        var scale = 1.toDouble();
        if (targetAspect > parentAspect) {
          scale = parentSize.width / simulatedSize.width;
        } else {
          scale = parentSize.height / simulatedSize.height;
        }

        final marginFactor = showBezel ? 0.9 : 1.toDouble();
        scale *= marginFactor;

        final finalWidth = simulatedSize.width * scale;
        final finalHeight = simulatedSize.height * scale;

        return Container(
          color: Colors.grey[950],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showBezel) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${config.name} (${config.width.toInt()} × ${config.height.toInt()})',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
                Container(
                  width: finalWidth,
                  height: finalHeight,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    boxShadow: showBezel
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                    border: showBezel
                        ? Border.all(color: Colors.grey[800]!, width: 4)
                        : null,
                  ),
                  child: ClipRect(
                    child: FittedBox(
                      child: SizedBox(
                        width: simulatedSize.width,
                        height: simulatedSize.height,
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            size: simulatedSize,
                            padding: EdgeInsets.zero,
                            viewPadding: EdgeInsets.zero,
                            viewInsets: EdgeInsets.zero,
                            navigationMode: config.isTv
                                ? NavigationMode.directional
                                : NavigationMode.traditional,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
