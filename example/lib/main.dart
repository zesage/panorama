import 'dart:io';
import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Panorama',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Flutter Panorama'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _imageFile;
  double _lon = 0;
  double _lat = 0;
  double _tilt = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Panorama(
            animSpeed: 1.0,
            sensorControl: SensorControl.Orientation,
            onViewChanged: (longitude, latitude, tilt) {
              setState(() {
                _lon = longitude;
                _lat = latitude;
                _tilt = tilt;
              });
            },
            child: _imageFile != null ? Image.file(_imageFile) : Image.asset('assets/panorama.jpg'),
          ),
          Text('${_lon.toStringAsFixed(3)}, ${_lat.toStringAsFixed(3)}, ${_tilt.toStringAsFixed(3)}'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () async {
          _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
          setState(() {});
        },
        child: Icon(Icons.panorama),
      ),
    );
  }
}
