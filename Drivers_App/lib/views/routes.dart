

import 'package:bus_drivers_app/views/set_locator.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Routes_View extends StatefulWidget {
  CollectionReference users;
   String  id;
   Routes_View({super.key,required this.users,required this.id});

  @override
  State<Routes_View> createState() => _Routes_ViewState();
}

class _Routes_ViewState extends State<Routes_View> {

  late CollectionReference routesdb;

   @override
  void initState() {
    // TODO: implement initState
     routesdb=widget.users.doc(widget.id).collection('routes');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routes"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
              Image.asset('assets/route.png',width: 200,height: 200,fit: BoxFit.cover,),
              Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: routesdb.snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(),);
                  }
                 final data=snapshot.requireData;
                  return ListView.builder(
                      itemCount: data.size,
                      itemBuilder: (context,idx) {
                        QueryDocumentSnapshot dataOfDoc=data.docs[idx];
                        // return
                        //   ListTile(
                        //   title: Text(dataOfDoc.get('routeStart')),
                        //   onTap: (){
                        //     //print(data.docs[idx]['routes']);
                        //     Navigator.push(context, MaterialPageRoute(builder: (context)=> mapView(route:routesdb.doc(dataOfDoc.id))));
                        //   },
                        // );

                        return InkWell(
                          child: Container(
                            height: 80,
                            margin: EdgeInsets.fromLTRB(0,7,0,7),
                            padding: EdgeInsets.all(7),
                            color: Colors.indigo.shade100,
                            child: Center(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("From : "+dataOfDoc.get('routeStart'))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Via : "+dataOfDoc.get('routeVia'))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text("To : "+dataOfDoc.get('routeEnd'))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                      onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context)=> SetLocation(route:routesdb.doc(dataOfDoc.id))));
                           },
                        );
                      }
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
