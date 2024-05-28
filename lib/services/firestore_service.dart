import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:mapbox_firebase_app/models/location_model.dart';

class FirestoreService extends ChangeNotifier{

  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference _location;

  FirestoreService(){
    _location = _firestore.collection("location").withConverter<Location>(
      fromFirestore: (snapshots, _ ) => Location.fromJson(snapshots.data()!,), 
      toFirestore: (location, _ ) => location.toJson());
  }

  Stream<QuerySnapshot> getLocations() async* {
    yield*  _firestore.collection("location").snapshots();
  }

  void addLocation(Location location) async {
    _location.add(location);
  }

  void deleteLocation(String id) async{
    _location.doc(id).delete();
  }

}