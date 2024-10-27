import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

class MapWidget extends StatefulWidget {
  final double sourceLat;
  final double sourceLng;
  final double destLat;
  final double destLng;
  final bool? isVisible;

  const MapWidget({
    super.key,
    required this.sourceLat,
    required this.sourceLng,
    required this.destLat,
    required this.destLng,
    this.isVisible,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController _mapController;
  CameraPosition? _currentCameraPosition;
  final Set<Marker> _markers = {};
  BitmapDescriptor? customMarker;
  BitmapDescriptor? customDestinationMarker;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "put_your_google_api_key_here";  // !important
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Geolocator.requestPermission().then((value) {
        getCurrentLocation();
      });
    });

    getBytesFromCanvas(50, 80, 'assets/images/car2.png').then((bitmap) {
      setState(() {
        customMarker = BitmapDescriptor.fromBytes(bitmap);
        if (customMarker != null) {
          _addMarker(
            LatLng(widget.sourceLat, widget.sourceLng),
            "source",
            customMarker!,
          );
        }
      });
    });

    getBytesFromCanvas(100, 100, 'assets/icons/destination_pin.png').then((bitmap) {
      setState(() {
        customDestinationMarker = BitmapDescriptor.fromBytes(bitmap);
        if (customDestinationMarker != null) {
          _addMarker(
            LatLng(widget.destLat, widget.destLng),
            "destination",
            customDestinationMarker!,
          );
        }
      });
    });

    //  polyline b/w source & destination
    _getPolyline(widget.sourceLat, widget.sourceLng, widget.destLat, widget.destLng);
  }

  void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
    setState(() {});
  }

  Future<Uint8List> getBytesFromCanvas(int width, int height, String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.transparent;

    final Radius radius = Radius.circular(20.0);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: radius,
      ),
      paint,
    );

    canvas.drawImageRect(
      fi.image,
      Rect.fromLTWH(0, 0, fi.image.width.toDouble(), fi.image.height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint(),
    );

    final img = await pictureRecorder.endRecording().toImage(width, height);
    final dataBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return dataBytes!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible ?? true,
      child: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : GoogleMap(
        initialCameraPosition: _currentCameraPosition ??
            CameraPosition(
              target: LatLng(widget.sourceLat, widget.sourceLng),
              zoom: 11.8,
            ),
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          mapCreated(controller);
        },
        indoorViewEnabled: true,
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
        cameraTargetBounds: CameraTargetBounds(
          LatLngBounds(
            northeast: LatLng(max(widget.sourceLat, widget.destLat), max(widget.sourceLng, widget.destLng)),
            southwest: LatLng(min(widget.sourceLat, widget.destLat), min(widget.sourceLng, widget.destLng)),
          ),
        ),
      ),
    );
  }

  void mapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  Future<void> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final latLng = LatLng(position.latitude, position.longitude);

    _currentCameraPosition = CameraPosition(target: latLng, zoom: 15);
    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: latLng,
        icon: BitmapDescriptor.defaultMarker,
      ),
    );

    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: latLng, zoom: 15),
    ));
  }

  Future<void> _getPolyline(double originLatitude, double originLongitude, double destLatitude, double destLongitude) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleAPiKey, 
      request: PolylineRequest(
        origin: PointLatLng(originLatitude, originLongitude),
        destination: PointLatLng(destLatitude, destLongitude),
        mode: TravelMode.driving, 
        wayPoints: [],
      ),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      _addPolyLine();
      setState(() {
          _isLoading = false;
      });
    } else {
      print("Error: ${result.errorMessage}");
      setState(() {
          _isLoading = false;
      });
    }

    await focusCameraOnPolyline();
  }

  void _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      width: 5,
      color: Colors.blue, 
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Future<void> focusCameraOnPolyline() async {
    if (polylineCoordinates.isEmpty) return;

    double minLat = double.infinity, maxLat = -double.infinity;
    double minLng = double.infinity, maxLng = -double.infinity;

    for (LatLng point in polylineCoordinates) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
}
