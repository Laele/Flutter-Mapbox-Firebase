import 'package:flutter/material.dart';
import 'package:mapbox_firebase_app/providers/bottomSheet_controller.dart';
import 'package:provider/provider.dart';

import 'package:mapbox_firebase_app/styles/styles.dart';
import 'package:mapbox_firebase_app/models/location_model.dart';
import 'package:mapbox_firebase_app/services/firestore_service.dart';
import 'package:mapbox_firebase_app/services/geolocator_service.dart';
import 'package:mapbox_firebase_app/services/mapbox_search_service.dart';

class MainBottomSheetPage extends StatefulWidget {
  const MainBottomSheetPage({super.key});

  @override
  State<MainBottomSheetPage> createState() => _MainBottomSheetPageState();
}

class _MainBottomSheetPageState extends State<MainBottomSheetPage> {

  @override
  Widget build(BuildContext context) {

    final MapboxSearchService mapboxSearchService = Provider.of<MapboxSearchService>(context);
    final GeolocatorService geolocatorService = Provider.of<GeolocatorService>(context);
    final FirestoreService firestoreService = Provider.of<FirestoreService>(context);
    final BottomSheetController bottomSheetController = Provider.of<BottomSheetController>(context);

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          title: Text('Showing Location', 
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.red,
          pinned: true,
        ),

        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const Text('Target Location'),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Lat: ${geolocatorService.lat.toString()}'),
                    Text('Long: ${geolocatorService.long.toString()}'),
                  ],
                ),

                const SizedBox(height: 5,),
                
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 3),
                  decoration:  BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey.shade300
                    
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [     
                                
                      _RedLocationIcon(),
                                
                      const SizedBox(width: 10),

                      ValueListenableBuilder<String>(
                        valueListenable: mapboxSearchService.placeName, 
                        builder: (context, value, child) {
                          return Expanded(child: Text(mapboxSearchService.placeName.value.toString(), overflow: TextOverflow.ellipsis,));
                        },
                        
                      ),
                  
                      FilledButton(onPressed: (){
                        geolocatorService.setLatLong(
                          latitud: mapboxSearchService.redCircle.options.geometry!.latitude,
                          longitud: mapboxSearchService.redCircle.options.geometry!.longitude
                          );
          
                        mapboxSearchService.getAddressbyLatLong(
                          geolocatorService.lat,
                          geolocatorService.long
                        );
                        
                        print(mapboxSearchService.redCircle.options.geometry);
                        setState(() {});
              
                      },
                      style: ButtonStyle1(), 
                      child: const Text('Confirm', style: TextStyle(color: Colors.white),))
                    ],
                  ),
                ),
                          
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    
                    child: Row(
                      children: [

                        // Save Location Button
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: (){ 
                                    Location location = Location(
                                      latitude: mapboxSearchService.redCircle.options.geometry!.latitude, 
                                      longitude: mapboxSearchService.redCircle.options.geometry!.longitude, 
                                      locationName: mapboxSearchService.placeName.value
                                    );
                                    firestoreService.addLocation(location);
                                    const snackBar = SnackBar(
                                      content: Text('Location Added!'),
                                      duration: Duration(seconds: 1),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  },
                                  icon: const Icon(Icons.save, size: 40, color: Colors.white,)
                                  )
                              ),
                              const SizedBox(height: 10),
                              Text('Save Location', style: Theme.of(context).textTheme.labelLarge)
                            ],
                          ),
                        ),

                        // Show Locations Button
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () async { 
                                    bottomSheetController.currentPage.value = 1;
                                  },
                                  icon: const Icon(Icons.map, size: 40, color: Colors.white,)
                                  )
                              ),
                              const SizedBox(height: 10,),
                              Text('Show Locations', style: Theme.of(context).textTheme.labelLarge,)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ]
            )
          )
        )
      ],
    );
  }
}

class _RedLocationIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(45),
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 20,)
    );
  }
}
