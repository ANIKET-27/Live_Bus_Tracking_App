
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'all_routes.dart';



class GetUserName extends StatefulWidget {
  @override
  State<GetUserName> createState() => _GetUserNameState();
}

class _GetUserNameState extends State<GetUserName> {
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('Depo');
     return Scaffold(
      appBar: AppBar(
        title: Text("Bus Depo"),
        centerTitle: true,
      ),
      body:Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
         children: [
           // SizedBox(height: 30,),
           Container(
             child: Image.asset('assets/busstop.png',width: 200,height: 200,fit: BoxFit.cover,),
           ),
           Expanded(
             child: StreamBuilder<QuerySnapshot>(
               stream: users.snapshots(),
               builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                 if (snapshot.hasError) {
                   return Center(child: Text('Something went wrong,Please Try Again'));
                 }

                 if (snapshot.connectionState == ConnectionState.waiting) {
                   return Center(child: CircularProgressIndicator());
                 }


                 final data=snapshot.requireData;
                 return ListView.builder(
                     itemCount: data.size,
                     itemBuilder: (context,idx) {
                       QueryDocumentSnapshot dataOfDoc=data.docs[idx];

                   return ListTile(
                    title: Text(dataOfDoc.get('depo_name')),
                     leading: Text(idx.toString()),
                      onTap: (){
                      //print(data.docs[idx]['routes']);
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> Routes_View(users:users, id:dataOfDoc.id,)));
                     },
                   );
                 }
                 );
               },
             ),
           ),
         ],
     ),
      )
    );
  }
}



// StreamBuilder<QuerySnapshot>(
// stream: users.snapshots(),
// builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
// if (snapshot.hasError) {
// return Text('Something went wrong');
// }
//
// if (snapshot.connectionState == ConnectionState.waiting) {
// return Text("Loading");
// }
//
//
// final data=snapshot.requireData;
// return ListView.builder(
// itemCount: data.size,
// itemBuilder: (context,idx) {
// QueryDocumentSnapshot f=data.docs[idx];
// return ListTile(
// title: Text(f.id),
// onTap: (){
// print(data.docs[idx]['depo_name']);
// },
// );
// }
// );
// },
// )