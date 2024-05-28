import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorService extends ChangeNotifier{

  Position? position;

  late double _lat;
  late double _long;

  bool _loading = false;

  bool gotPosition = false;

  GeolocatorService(){
    _determinePosition();
  }


  double get lat => _lat;
  double get long => _long;

  bool get loading => _loading;
  set loading(bool value){
    _loading = value;
    notifyListeners();
  } 

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    }

    position =  await Geolocator.getCurrentPosition();
    this.gotPosition = true;
    this._lat = position!.latitude;
    this._long = position!.longitude;

    notifyListeners();
    return;
  }

  Future<void> getCurrentLocation() async => position = await Geolocator.getCurrentPosition();

  void setLatLong({required double latitud, required double longitud }){
    this._lat = latitud;
    this._long = longitud;
    position = Position(longitude: _long, latitude: _lat, timestamp: DateTime.now(), accuracy: 0.0, altitude: 0.0, altitudeAccuracy: 0.0, heading: 0.0, headingAccuracy: 0.0, speed: 0.0, speedAccuracy: 0.0);
  }

}