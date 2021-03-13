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
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

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
    Image.asset('assets/panorama_cropped.webp'),
  ];
  ImagePicker picker = ImagePicker();

  void onViewChanged(longitude, latitude, tilt) {
    setState(() {
      _lon = longitude;
      _lat = latitude;
      _tilt = tilt;
    });
  }

  Widget hotspotButton({String? text, IconData? icon, VoidCallback? onPressed}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(CircleBorder()),
            backgroundColor: MaterialStateProperty.all(Colors.black38),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
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
    Widget panorama;
    switch (_panoId % panoImages.length) {
      case 0:
        panorama = Panorama(
          animSpeed: 1.0,
          sensorControl: SensorControl.Orientation,
          onViewChanged: onViewChanged,
          onTap: (longitude, latitude, tilt) => print('onTap: $longitude, $latitude, $tilt'),
          onLongPressStart: (longitude, latitude, tilt) => print('onLongPressStart: $longitude, $latitude, $tilt'),
          onLongPressMoveUpdate: (longitude, latitude, tilt) => print('onLongPressMoveUpdate: $longitude, $latitude, $tilt'),
          onLongPressEnd: (longitude, latitude, tilt) => print('onLongPressEnd: $longitude, $latitude, $tilt'),
          child: Image.asset('assets/panorama.jpg'),
          hotspots: [
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
              widget: hotspotButton(icon: Icons.search, onPressed: () => setState(() => _panoId = 2)),
            ),
            Hotspot(
              latitude: -33.0,
              longitude: 123.0,
              width: 60.0,
              height: 60.0,
              widget: hotspotButton(icon: Icons.arrow_upward, onPressed: () {}),
            ),
          ],
        );
        break;
      case 2:
        panorama = Panorama(
          animSpeed: 1.0,
          sensorControl: SensorControl.Orientation,
          onViewChanged: onViewChanged,
          croppedArea: Rect.fromLTWH(2533.0, 1265.0, 5065.0, 2533.0),
          croppedFullWidth: 10132.0,
          croppedFullHeight: 5066.0,
          child: Image.asset('assets/panorama_cropped.jpg'),
          hotspots: [
            Hotspot(
              latitude: 0.0,
              longitude: -46.0,
              width: 90.0,
              height: 75.0,
              widget: hotspotButton(text: "Next scene", icon: Icons.double_arrow, onPressed: () => setState(() => _panoId++)),
            ),
          ],
        );
        break;
      default:
        panorama = Panorama(
          animSpeed: 1.0,
          sensorControl: SensorControl.Orientation,
          onViewChanged: onViewChanged,
          child: panoImages[_panoId % panoImages.length],
          hotspots: [
            Hotspot(
              latitude: 0.0,
              longitude: 160.0,
              width: 90.0,
              height: 75.0,
              widget: hotspotButton(text: "Next scene", icon: Icons.double_arrow, onPressed: () => setState(() => _panoId++)),
            ),
          ],
        );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Stack(
        children: [
          panorama,
          Text('${_lon.toStringAsFixed(3)}, ${_lat.toStringAsFixed(3)}, ${_tilt.toStringAsFixed(3)}'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () async {
          final pickedFile = await picker.getImage(source: ImageSource.gallery);
          setState(() {
            if (pickedFile != null) {
              panoImages.add(Image.file(File(pickedFile.path)));
              _panoId = panoImages.length - 1;
            }
          });
        },
        child: Icon(Icons.panorama),
      ),
    );
  }
}
