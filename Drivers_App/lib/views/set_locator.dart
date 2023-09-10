import 'dart:async';



import 'package:bus_drivers_app/depo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../globals.dart';



class SetLocation extends StatefulWidget {

  DocumentReference route;
  String driveId=Global.driverid;
  SetLocation({super.key,required this.route});

  @override
  State<SetLocation> createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {

late Position position;
late StreamSubscription<Position> livePosition;


@override
  void dispose() {

      stopLiveLocation();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Enable Location"),
          centerTitle: true,
        ),
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             ElevatedButton(onPressed: (){
             startLiveLocation(handlePosition);
            }, child: Text("Enable Live Location")),
            ElevatedButton(onPressed: (){
               stopLiveLocation();
            }, child: Text("Stop Live Location")),
          ],
        )
      )

    );
  }



  handlePosition(Position position) async {
       FirebaseFirestore.instance.collection("Drivers")
          .doc(widget.driveId)
          .set(
          {
            "latitude": position.latitude,
            "longitude": position.longitude
          },
          SetOptions(merge: true)
      );
  }

  accessGranted(LocationPermission permission){
    return permission== LocationPermission.whileInUse ||
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


   Future<void> startLiveLocation(Function(Position position) callback) async {
    bool permission = await requestPermission();
    if(!permission){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Unsuccessfull, Location Not Endabled"),backgroundColor: Colors.red,));

    }
    await widget.route.set({
        'buses_running': FieldValue.arrayUnion([widget.driveId])
    },
      SetOptions(merge: true)
    ).then((value){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Bus Added Successfully to Route"),backgroundColor: Colors.green,));
    }).onError((error, stackTrace){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Unsuccesfull ,Try Again"),backgroundColor: Colors.red,));
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Live Location Enabled Successfully"),backgroundColor: Colors.green,));
    livePosition = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.bestForNavigation)
    ).listen((callback));

}

  Future<void> stopLiveLocation() async {
   livePosition.cancel();
    await widget.route.set({
      'buses_running': FieldValue.arrayRemove([widget.driveId])
    },
        SetOptions(merge: true)
    ).onError((error, stackTrace){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Unsuccesfull ,Try Again"),backgroundColor: Colors.red,));
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Disabled Successfully"),backgroundColor: Colors.green,));
  }
}


