import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_firebase_app/services/geolocator_service.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';

import 'package:mapbox_firebase_app/services/mapbox_search_service.dart';
import 'package:mapbox_firebase_app/widgets/bottom_sheet_map_widget.dart';


class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future loading () async { 
    MapboxSearchService mapboxSearchService = Provider.of<MapboxSearchService>(context,listen: false);
    await Future.delayed(const Duration(seconds: 2));
    mapboxSearchService.mapCreated = true;
    setState(() { });
  }

  void _onMapCreated(MapboxMapController controller) {
    final MapboxSearchService mapboxSearchService = Provider.of<MapboxSearchService>(context,listen: false);
    mapboxSearchService.controller = controller;
    mapboxSearchService.controller.addListener(() {
      setState(() {
      });
    });

  }

  void _onStyleLoadedCallback() {
    final MapboxSearchService mapboxSearchService = Provider.of<MapboxSearchService>(context,listen: false);
    final GeolocatorService geolocatorService = Provider.of<GeolocatorService>(context, listen: false);
    mapboxSearchService.controller.addCircle(  CircleOptions(
      geometry: LatLng(geolocatorService.position!.latitude, geolocatorService.position!.longitude),
      circleColor: "#00B9FF", 
      circleRadius: 10,
      draggable: false
    ));


     mapboxSearchService.controller.addCircle(  CircleOptions(
      geometry: LatLng(geolocatorService.position!.latitude, geolocatorService.position!.longitude + 0.0001),
      circleColor: "#FF0000", 
      circleRadius: 10,
      draggable: true
    ));
    mapboxSearchService.blueCircle = mapboxSearchService.controller.circles.first;
    mapboxSearchService.redCircle = mapboxSearchService.controller.circles.last;
    mapboxSearchService.getAddressbyLatLong(
      mapboxSearchService.redCircle.options.geometry!.latitude,
      mapboxSearchService.redCircle.options.geometry!.longitude
    );
    loading();
  }

  @override
  Widget build(BuildContext context) {

    final MapboxSearchService mapboxSearchService = Provider.of<MapboxSearchService>(context);
    final GeolocatorService geolocatorService = Provider.of<GeolocatorService>(context);

    return Scaffold(
      body: Stack(
        children: [
          geolocatorService.gotPosition ? 
          MapboxMap(
            accessToken: const String.fromEnvironment('ACCESS_TOKEN'),
            initialCameraPosition: CameraPosition(target: LatLng(geolocatorService.position!.latitude, geolocatorService.position!.longitude),zoom: 17.5),

            trackCameraPosition: true,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoadedCallback,
          ) : const Center(child: CircularProgressIndicator()),

           SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                mapboxSearchService.mapCreated ? 
                  Text('Moving ${mapboxSearchService.controller.isCameraMoving}', style: const TextStyle(color: Colors.red, fontSize: 20),)
                  : const SizedBox(),

                const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.blue,),
                    Text('User Location')
                  ],
                ),

                 const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.red,),
                    Text('Target Location'),
                  ],
                ),

                geolocatorService.loading ? const CircularProgressIndicator() : const SizedBox(),
              ],
            ),
          ),
        ]
      ),

      bottomSheet: mapboxSearchService.mapCreated ?  BottomSheetMap() : const SizedBox(),

      floatingActionButton: mapboxSearchService.mapCreated ? Badge(
        smallSize: 25,
        largeSize: 25,
        backgroundColor: Colors.red,
        padding: const EdgeInsets.all(0),
        
        label: const Icon(Icons.update, color: Colors.white, size: 25,),
        offset: const Offset(5, 35),
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
          onPressed: () async {
      
          geolocatorService.loading = true;
          await geolocatorService.getCurrentLocation();
      
          final double lat = geolocatorService.position!.latitude;
          final double long = geolocatorService.position!.longitude;
      
          await  mapboxSearchService.controller.updateCircle(
              mapboxSearchService.redCircle, 
                CircleOptions( geometry: LatLng(lat, long + 0.0001) ) );
      
          await  mapboxSearchService.controller.updateCircle(
              mapboxSearchService.blueCircle, 
                CircleOptions( geometry: LatLng(lat, long) ) );
            
          await mapboxSearchService.controller.animateCamera( CameraUpdate.newLatLng( LatLng(lat, long) ) );
            
          mapboxSearchService.getAddressbyLatLong( lat, long );
          
          setState(() {});
          geolocatorService.loading = false;
          },
          child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 35,)
        ),
      ) : const SizedBox(),
    );
  }
}

