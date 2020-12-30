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
  double _lon = 0;
  double _lat = 0;
  double _tilt = 0;
  int _panoId = 0;
  List<Image> panoImages = [
    Image.asset('assets/panorama.jpg'),
    Image.asset('assets/panorama2.webp'),
  ];

  Widget hotspotButton({String text, IconData icon, VoidCallback onPressed}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlatButton(
          shape: CircleBorder(),
          color: Colors.black38,
          child: Icon(icon),
          onPressed: onPressed,
        ),
        text != null
            ? Container(
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Center(child: Text(text)),
              )
            : Container(),
      ],
    );
  }

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
            child: panoImages[_panoId % panoImages.length],
            hotspots: _panoId % panoImages.length == 0
                ? [
                    Hotspot(
                      latitude: -15.0,
                      longitude: -129.0,
                      width: 90,
                      height: 75,
                      widget: hotspotButton(text: "Next scene", icon: Icons.open_in_browser, onPressed: () => setState(() => _panoId++)),
                    ),
                    Hotspot(
                      latitude: -42.0,
                      longitude: -46.0,
                      width: 60.0,
                      height: 60.0,
                      widget: hotspotButton(icon: Icons.search, onPressed: () {}),
                    ),
                    Hotspot(
                      latitude: -33.0,
                      longitude: 123.0,
                      width: 60.0,
                      height: 60.0,
                      widget: hotspotButton(icon: Icons.arrow_upward, onPressed: () {}),
                    ),
                  ]
                : [
                    Hotspot(
                      latitude: 0.0,
                      longitude: 160.0,
                      width: 90.0,
                      height: 75.0,
                      widget: hotspotButton(text: "Next scene", icon: Icons.double_arrow, onPressed: () => setState(() => _panoId++)),
                    ),
                  ],
          ),
          Text('${_lon.toStringAsFixed(3)}, ${_lat.toStringAsFixed(3)}, ${_tilt.toStringAsFixed(3)}'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
            setState(() {
              panoImages.add(Image.file(value));
              _panoId = panoImages.length - 1;
            });
          });
        },
        child: Icon(Icons.panorama),
      ),
    );
  }
}
