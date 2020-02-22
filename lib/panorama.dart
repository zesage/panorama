library panorama;

import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Panorama extends StatefulWidget {
  Panorama({
    Key key,
    this.latitude = 0,
    this.longitude = 0,
    this.zoom = 1.0,
    this.minLatitude = -90.0,
    this.maxLatitude = 90.0,
    this.minLongitude = -180.0,
    this.maxLongitude = 180.0,
    this.minZoom = 1.0,
    this.maxZoom = 5.0,
    this.sensitivity = 1.0,
    this.animSpeed = 1.0,
    this.animReverse = true,
    this.latSegments = 32,
    this.lonSegments = 64,
    this.interactive = true,
    this.child,
  }) : super(key: key);

  /// The initial latitude, in degrees, between -90 and 90. default to 0
  final double latitude;

  /// The initial longitude, in degrees, between -180 and 180. default to 0
  final double longitude;

  /// The initial zoom, default to 1.0.
  final double zoom;

  /// The minimal latitude to show. default to -90.0
  final double minLatitude;

  /// The maximal latitude to show. default to 90.0
  final double maxLatitude;

  /// The minimal longitude to show. default to -180.0
  final double minLongitude;

  /// The maximal longitude to show. default to 180.0
  final double maxLongitude;

  /// The minimal zomm. default to 1.0
  final double minZoom;

  /// The maximal zomm. default to 5.0
  final double maxZoom;

  /// The sensitivity of the gesture. default to 1.0
  final double sensitivity;

  /// The Speed of rotation by animation. default to 1.0
  final double animSpeed;

  /// Reverse rotation when the current longitude reaches the minimal or maximum. default to true
  final bool animReverse;

  /// The number of vertical divisions of the sphere.
  final int latSegments;

  /// The number of horizontal divisions of the sphere.
  final int lonSegments;

  /// Interact with the panorama. default to true
  final bool interactive;

  /// Specify an Image(equirectangular image) widget to the panorama.
  final Image child;

  @override
  _PanoramaState createState() => _PanoramaState();
}

class _PanoramaState extends State<Panorama> with SingleTickerProviderStateMixin {
  Scene scene;
  double latitude;
  double longitude;
  double latitudeDelta = 0;
  double longitudeDelta = 0;
  double zoomDelta = 0;
  Offset _lastFocalPoint;
  double _lastZoom;
  double _radius = 500;
  double _dampingFactor = 0.05;
  double _animateDirection = 1.0;
  AnimationController _controller;

  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.localFocalPoint;
    _lastZoom = null;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final offset = details.localFocalPoint - _lastFocalPoint;
    _lastFocalPoint = details.localFocalPoint;
    latitudeDelta += widget.sensitivity * 0.5 * math.pi * offset.dy / scene.camera.viewportHeight;
    longitudeDelta -= widget.sensitivity * _animateDirection * 0.5 * math.pi * offset.dx / scene.camera.viewportHeight;
    if (_lastZoom == null) {
      _lastZoom = scene.camera.zoom;
    }
    zoomDelta += _lastZoom * details.scale - (scene.camera.zoom + zoomDelta);
    if (!_controller.isAnimating) {
      _controller.reset();
      if (widget.animSpeed != 0) {
        _controller.repeat();
      } else
        _controller.forward();
    }
  }

  void _onSceneCreated(Scene scene) {
    this.scene = scene;
    scene.camera.near = 1.0;
    scene.camera.far = _radius + 1.0;
    scene.camera.fov = 75;
    scene.camera.zoom = widget.zoom;
    scene.camera.position.setFrom(Vector3(0, 0, 0.1));
    setCameraTarget(latitude, longitude);

    if (widget.child != null) {
      loadImageFromProvider(widget.child.image).then((ui.Image image) {
        final Mesh mesh = generateSphereMesh(radius: _radius, latSegments: widget.latSegments, lonSegments: widget.lonSegments, texture: image);
        scene.world.add(Object(name: 'surface', mesh: mesh, backfaceCulling: false));
        scene.updateTexture();
      });
    }
  }

  void setCameraTarget(double latitude, double longitude) {
    longitude += math.pi;
    scene.camera.target.x = math.cos(longitude) * math.cos(latitude) * _radius;
    scene.camera.target.y = math.sin(latitude) * _radius;
    scene.camera.target.z = math.sin(longitude) * math.cos(latitude) * _radius;
    scene.update();
  }

  @override
  void initState() {
    super.initState();
    latitude = widget.latitude;
    longitude = widget.longitude;

    _controller = AnimationController(duration: Duration(milliseconds: 60000), vsync: this)
      ..addListener(() {
        if (scene == null) return;
        longitudeDelta += 0.001 * widget.animSpeed;
        if (latitudeDelta.abs() < 0.001 && longitudeDelta.abs() < 0.001 && zoomDelta.abs() < 0.001) {
          if (widget.animSpeed == 0 && _controller.isAnimating) _controller.stop();
          return;
        }
        // animate vertical rotating
        latitude += latitudeDelta * _dampingFactor * widget.sensitivity;
        latitudeDelta *= 1 - _dampingFactor * widget.sensitivity;
        latitude = latitude.clamp(radians(math.max(-89, widget.minLatitude)), radians(math.min(89, widget.maxLatitude)));
        // animate horizontal rotating
        longitude += _animateDirection * longitudeDelta * _dampingFactor * widget.sensitivity;
        longitudeDelta *= 1 - _dampingFactor * widget.sensitivity;
        if (widget.maxLongitude - widget.minLongitude < 360) {
          final double lon = longitude.clamp(radians(widget.minLongitude), radians(widget.maxLongitude));
          if (longitude != lon) {
            longitude = lon;
            if (widget.animSpeed != 0) {
              if (widget.animReverse) {
                _animateDirection *= -1.0;
              } else
                _controller.stop();
            }
          }
        }
        // animate zomming
        final double zoom = scene.camera.zoom + zoomDelta * _dampingFactor;
        zoomDelta *= 1 - _dampingFactor;
        scene.camera.zoom = zoom.clamp(widget.minZoom, widget.maxZoom);
        setCameraTarget(latitude, longitude);
      });
    if (widget.animSpeed != 0) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Panorama oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Object surface = scene.world.find(RegExp('surface'));
    if (surface == null) return;
    if (widget.latSegments != oldWidget.latSegments || widget.lonSegments != oldWidget.lonSegments) {
      surface.mesh = generateSphereMesh(radius: _radius, latSegments: widget.latSegments, lonSegments: widget.lonSegments, texture: surface.mesh.texture);
    }
    if (widget.child?.image != oldWidget.child?.image) {
      loadImageFromProvider(widget.child.image).then((ui.Image image) {
        surface.mesh.texture = image;
        surface.mesh.textureRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
        scene.updateTexture();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.interactive
        ? GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            child: Cube(interactive: false, onSceneCreated: _onSceneCreated),
          )
        : Cube(interactive: false, onSceneCreated: _onSceneCreated);
  }
}

Mesh generateSphereMesh({num radius = 1.0, int latSegments = 16, int lonSegments = 16, ui.Image texture}) {
  int count = (latSegments + 1) * (lonSegments + 1);
  List<Vector3> vertices = List<Vector3>(count);
  List<Offset> texcoords = List<Offset>(count);
  List<Polygon> indices = List<Polygon>(latSegments * lonSegments * 2);

  int i = 0;
  for (int y = 0; y <= latSegments; ++y) {
    final double v = y / latSegments;
    final double sv = math.sin(v * math.pi);
    final double cv = math.cos(v * math.pi);
    for (int x = 0; x <= lonSegments; ++x) {
      final double u = x / lonSegments;
      vertices[i] = Vector3(radius * math.cos(u * math.pi * 2.0) * sv, radius * cv, radius * math.sin(u * math.pi * 2.0) * sv);
      texcoords[i] = Offset(u, 1.0 - v);
      i++;
    }
  }

  i = 0;
  for (int y = 0; y < latSegments; ++y) {
    final int base1 = (lonSegments + 1) * y;
    final int base2 = (lonSegments + 1) * (y + 1);
    for (int x = 0; x < lonSegments; ++x) {
      indices[i++] = Polygon(base1 + x, base1 + x + 1, base2 + x);
      indices[i++] = Polygon(base1 + x + 1, base2 + x + 1, base2 + x);
    }
  }

  final Mesh mesh = Mesh(vertices: vertices, texcoords: texcoords, indices: indices, texture: texture);
  return mesh;
}

/// Get ui.Image from ImageProvider
Future<ui.Image> loadImageFromProvider(ImageProvider provider) async {
  final Completer<ui.Image> completer = Completer<ui.Image>();
  final ImageStream imageStream = provider.resolve(ImageConfiguration());
  ImageStreamListener listener;
  listener = ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
    completer.complete(imageInfo.image);
    imageStream.removeListener(listener);
  });
  imageStream.addListener(listener);
  return completer.future;
}
