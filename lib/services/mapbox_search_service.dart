import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mapbox_search/mapbox_search.dart';

class MapboxSearchService extends ChangeNotifier{

  late MapboxMapController _controller;
  late Circle _redCircle;
  late Circle _blueCircle;
  bool _mapCreated = false;

  final  placeName = ValueNotifier('');

  Circle get redCircle => _redCircle;
  set redCircle(Circle circle){
    _redCircle = circle;
    notifyListeners();
  }

  Circle get blueCircle => _blueCircle;
  set blueCircle(Circle circle){
    _blueCircle = circle;
    notifyListeners();
  }

  bool get mapCreated => _mapCreated;
  set mapCreated(bool value){
    _mapCreated = value;
    notifyListeners();
  } 

  MapboxMapController get controller => _controller;
  set controller(MapboxMapController controller){
    _controller = controller;
    notifyListeners();
  } 
    
  final  geoCodingService = GeoCoding(
    apiKey: const String.fromEnvironment('ACCESS_TOKEN'),
    limit: 5,
    types: [PlaceType.address]
  );

  Future<void> getAddressbyLatLong(double lat, double long) async {
    print('Request API');
    var addresses = await geoCodingService.getAddress((
      lat: lat, 
      long: long,
    ));

    if(addresses.success != null){ 
      placeName.value = addresses.success!.first.placeName!;
      return;
    }else{
      return null;  
    } 
  }
}
