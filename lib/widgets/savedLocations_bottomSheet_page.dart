import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mapbox_firebase_app/services/geolocator_service.dart';
import 'package:mapbox_firebase_app/services/mapbox_search_service.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';


import 'package:mapbox_firebase_app/models/location_model.dart';
import 'package:mapbox_firebase_app/providers/bottomSheet_controller.dart';
import 'package:mapbox_firebase_app/services/firestore_service.dart';

class SavedlocationsBottomSheetPage extends StatefulWidget {
  const SavedlocationsBottomSheetPage({super.key});

  @override
  State<SavedlocationsBottomSheetPage> createState() => _SavedlocationsBottomsheetPageState();
}

class _SavedlocationsBottomsheetPageState extends State<SavedlocationsBottomSheetPage> {
  
  StreamController controller = StreamController.broadcast();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.addStream(Provider.of<FirestoreService>(context,listen: false).getLocations());
  }

  @override
  Widget build(BuildContext context) {  

    final  BottomSheetController bottomSheetController = Provider.of<BottomSheetController>(context);
    final GeolocatorService geolocatorService = Provider.of<GeolocatorService>(context);
    final MapboxSearchService mapboxSearchService = Provider.of<MapboxSearchService>(context);
    final FirestoreService firestoreService = Provider.of<FirestoreService>(context);

    return StreamBuilder(
          stream: controller.stream, 
          builder: (context, snapshot) {
            
            if(snapshot.connectionState == ConnectionState.waiting){
              return CustomScrollView(
                slivers: [
                  _SliverAppBarLocations(bottomSheetController: bottomSheetController),

                   const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.red,)))
                ]
              );
            }

            if(snapshot.hasData){
              List locations = snapshot.data!.docs;

              return locations.isNotEmpty ?  CustomScrollView(
                slivers: [

                  _SliverAppBarLocations(bottomSheetController: bottomSheetController),

                  SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                    Location location = Location.fromJson(locations[index].data());

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      title: Container(
                        child: Text(location.locationName, 
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ),
                        leading: Container(
                          child: IconButton(
                            icon: const Icon(Icons.loupe_outlined, color: Colors.red ,), 
                            onPressed: () async { 
                          
                              geolocatorService.loading = true;
                              
                              geolocatorService.setLatLong(
                                latitud: location.latitude,
                                longitud: location.longitude
                                );
                          
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
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red ,), 
                          onPressed: () { 
                              String id = locations[index].id;
                              firestoreService.deleteLocation(id);
                            },
                        ),
                    );
                  },
                  childCount: locations.length
                  ))
                ],
              ) : 
              CustomScrollView(
                slivers: [ 
                  _SliverAppBarLocations(bottomSheetController: bottomSheetController),
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('No Locations Added')
                    )
                  )
                ]
              );
            }

            return CustomScrollView(
              slivers: [ 
                _SliverAppBarLocations(bottomSheetController: bottomSheetController),
                const SliverFillRemaining(
                  child: Center(
                    child: Text('No Locations Added')
                  )
                )
              ]
            );
        },
      );
  }
}

class _SliverAppBarLocations extends StatelessWidget {
  const _SliverAppBarLocations({
    super.key,
    required this.bottomSheetController,
  });

  final BottomSheetController bottomSheetController;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Saved Locations', 
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: Colors.white),
      ),
      centerTitle: true,
      backgroundColor: Colors.red,
      pinned: true,
      leading: IconButton(
        onPressed: (){
          bottomSheetController.currentPage.value = 0;
        }, 
        icon: const Icon(Icons.arrow_back_sharp, color: Colors.white,)),
    );
  }
}