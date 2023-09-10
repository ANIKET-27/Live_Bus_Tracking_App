import 'package:bus_drivers_app/depo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'globals.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController tec=new TextEditingController();

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
       appBar: AppBar(
           title: Text("Authorizaiton"),
           centerTitle: true,
       ),

       body: Padding(
         padding: EdgeInsets.all(8),
         child: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Text("Verify Id Below"),
               TextField(
                 controller: tec,
                 decoration: InputDecoration(
                   hintText: "Enter Id Here",
                   hintStyle: TextStyle(color : Colors.black26)
                 ),
               ),
               SizedBox(height: 20,),
               ElevatedButton(onPressed: ( ){
                 verify();
               }, child: Text("Verify")),
             ],
           ),
         ),
       ),
    );
  }

  verify() async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wait!!"),backgroundColor: Colors.indigo,));
    try{
      var collectionRef = await FirebaseFirestore.instance.collection('Drivers');
      var doc = await collectionRef.doc(tec.text).get();
      if(doc.exists){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> GetUserName()));
        Global.set(tec.text);
      }
      else
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter A Valid ID"),backgroundColor: Colors.red,));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connection Failed"),backgroundColor: Colors.red,));
    }

  }

}
