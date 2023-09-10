import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class mapView extends StatefulWidget {
  final DocumentReference route;
   const mapView({super.key,required this.route});

  @override
  State<mapView> createState() => _mapViewState();
}

class _mapViewState extends State<mapView> {


  Map<MarkerId, Marker> markers = {};
  Map<MarkerId,Marker> drivers={};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyBgrRxieGLCO9iV4hTytoRGhRha5qDIJX8";

  Completer<GoogleMapController> controller = Completer();

  static final CameraPosition initialPosition = const CameraPosition(
      target: LatLng(23.05133796148818, 87.84034500744758),
      zoom: 8
  );

  @override
  void initState() {
    // TODO: implement initState

    requestPermission();
    addLocation();
    getPolyline();
    updateDriverLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Routes"),
        centerTitle: true,
      ),
      body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController ctrl) {
                controller.complete(ctrl);
              },
              polylines: Set<Polyline>.of(polylines.values),
              markers: Set<Marker>.from(markers.values),
              initialCameraPosition: initialPosition,
              mapType: MapType.normal,
            )
          ]
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         addLocation();
          updateDriverLocation();
          setState(() { });
          },
        child: Icon(Icons.refresh),
      ),
    );
  }

  accessGranted(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (accessGranted(permission)) {
      return true;
    }
    await Geolocator.requestPermission();
    return accessGranted(permission);
  }
 addPolyLine2() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  getPolyline() async {

    try {
      DocumentSnapshot documentSnapshot = await widget.route.get();

      LatLng start = await LatLng(documentSnapshot['start'].latitude,
          documentSnapshot['start'].longitude);
      LatLng via = await LatLng(documentSnapshot['via'].latitude,
          documentSnapshot['via'].longitude);
      LatLng end = await LatLng(documentSnapshot['end'].latitude,
          documentSnapshot['end'].longitude);

    PolylineResult result1 = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(via.latitude, via.longitude),
        travelMode: TravelMode.driving,

    );

    PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(via.latitude, via.longitude),
      PointLatLng(end.latitude, end.longitude),
      travelMode: TravelMode.driving,
    );

    if (result1.points.isNotEmpty) {
      result1.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    if (result2.points.isNotEmpty) {
      result2.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      );
    }

      markers[MarkerId('start')] =
          Marker(markerId: MarkerId('start'),
              position: LatLng(documentSnapshot['start'].latitude,
                  documentSnapshot['start'].longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta)
          );

      markers[MarkerId('via')] =
          Marker(markerId: MarkerId('via'),
              position: LatLng(documentSnapshot['via'].latitude,
                  documentSnapshot['via'].longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta)
          );

      markers[MarkerId('end')] =
          Marker(markerId: MarkerId('end'),
              position: LatLng(documentSnapshot['end'].latitude,
                  documentSnapshot['end'].longitude),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta)
          );


     addPolyLine2();

    }
    catch(e){
      print("Error Occured");
      print(e);
    }

  }

  updateDriverLocation() async{
    try{
      DocumentSnapshot documentSnapshot = await widget.route.get();
      var db=FirebaseFirestore.instance.collection('Drivers');
      List<dynamic> drivers = documentSnapshot['buses_running'];
      for (int i = 0; i < drivers.length; i++) {
        await db.doc(drivers[i].toString()).get().then((value){
          markers[MarkerId(drivers[i].toString())] = (
              Marker(markerId: MarkerId(drivers[i].toString()),
                position: LatLng(value['latitude'],value['longitude']),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              )
          );
        }
        );
       }
      setState(() {});
    }
    catch(e){
      print(e);
    }

  }

  addLocation() async{
    Position loc = await Geolocator.getCurrentPosition();
    markers[MarkerId("userLoc")]=
      Marker(markerId: MarkerId("userLoc"),
        position: LatLng(loc.latitude, loc.longitude),
        icon: BitmapDescriptor.defaultMarker,
      );
  }


}




