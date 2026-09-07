import 'package:dpad_qualification/dpad_qualification.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DpadQualificationExampleApp());
}

class DpadQualificationExampleApp extends StatelessWidget {
  const DpadQualificationExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-Pad Qualification Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      builder: (context, child) {
        return DeviceQualificationOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const DemoHomeScreen(),
    );
  }
}

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  int _selectedIndex = 0;

  final List<String> _categories = [
    'Live TV',
    'Movies',
    'TV Series',
    'Sports',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Smart TV Navigation Demo'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Use Arrow Keys or On-Screen Remote',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: _categories.map((category) {
              return NavigationRailDestination(
                icon: const Icon(Icons.tv),
                selectedIcon: const Icon(Icons.tv_sharp),
                label: Text(category),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category: ${_categories[_selectedIndex]}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.6,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        return FocusableTile(
                          title: 'Media Channel ${index + 1}',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FocusableTile extends StatefulWidget {
  final String title;

  const FocusableTile({super.key, required this.title});

  @override
  State<FocusableTile> createState() => _FocusableTileState();
}

class _FocusableTileState extends State<FocusableTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focused) {
        setState(() {
          _isFocused = focused;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isFocused ? Colors.deepPurpleAccent : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused ? Colors.white : Colors.grey[800]!,
            width: _isFocused ? 3 : 1,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_fill,
                size: _isFocused ? 48 : 36,
                color: _isFocused ? Colors.white : Colors.white70,
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
