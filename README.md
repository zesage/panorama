# Panorama

[![pub package](https://img.shields.io/pub/v/panorama.svg)](https://pub.dev/packages/panorama)

A 360-degree panorama viewer.

## Getting Started

Add panorama as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  panorama: ^0.4.1
```

Import and add the Panorama widget to your project.

```dart
import 'package:panorama/panorama.dart';
... ...
  
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Panorama(
          child: Image.asset('assets/panorama.jpg'),
        ),
      ),
    );
  }
```

## Screenshot

![screenshot](https://github.com/zesage/panorama/raw/master/resource/screenshot.gif)

## Usage Tutorials

* [Create a Panoramic Image Viewer in Flutter using the panorama plugin](https://developer.school/creating-a-panoramic-image-viewer-in-flutter-using-panorama-plugin/)
* [Flutter Panorama Plugin](https://www.youtube.com/watch?v=JYSJOQ86spc)
