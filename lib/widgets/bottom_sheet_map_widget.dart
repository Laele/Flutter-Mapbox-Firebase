import 'package:flutter/material.dart';
import 'package:mapbox_firebase_app/widgets/main_bottomSheet_page.dart';
import 'package:provider/provider.dart';

import 'package:mapbox_firebase_app/providers/bottomSheet_controller.dart';
import 'package:mapbox_firebase_app/services/mapbox_search_service.dart';
import 'package:mapbox_firebase_app/widgets/savedLocations_bottomSheet_page.dart';


class BottomSheetMap extends StatefulWidget {

  const BottomSheetMap({
    super.key,
  }) ;

  @override
  State<BottomSheetMap> createState() => _BottomSheetMapState();
}


class _BottomSheetMapState extends State<BottomSheetMap> {

  late List<Widget> pages = [
    //_MainPage(context),
    const MainBottomSheetPage(),
    const SavedlocationsBottomSheetPage(),
  ];

  @override
  Widget build(BuildContext context) {

    final  BottomSheetController bottomSheetController = Provider.of<BottomSheetController>(context);
    final  MapboxSearchService mapboxSearchService =  Provider.of<MapboxSearchService>(context);;
    return BottomSheet(
      enableDrag: false,
      showDragHandle: false,
      onClosing: (){}, 
      builder: (context) {
    
        return  mapboxSearchService.mapCreated ? AnimatedContainer(
          clipBehavior: Clip.hardEdge,
          height: mapboxSearchService.controller.isCameraMoving  ? 
          MediaQuery.of(context).size.height * 0.1
          : MediaQuery.of(context).size.height * 0.3,
    
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
          ), 
          duration: const Duration(milliseconds: 500),
    
          child: ValueListenableBuilder(
            valueListenable: bottomSheetController.currentPage, 
            builder: (context, value, child) {
              if(bottomSheetController.currentPage.value == 1) return pages[1];
                return pages[0];
            },
          )
  
        ): _EmptyBottomSheet();
      }
    );
  }
}

class _EmptyBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: MediaQuery.of(context).size.height * 0.3,
      decoration: const BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}