import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:search_map_place/search_map_place.dart';

import '../models/place.dart';

class MapScreen extends StatefulWidget {
  final PlaceLocation initialLocation;
  final bool isSelecting;
  final double zoom;

  MapScreen(
      {this.initialLocation =
          const PlaceLocation(latitude: 37.822, longitude: -121.99),
      this.isSelecting = false,
      this.zoom});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _pickedLocation;
  Completer<GoogleMapController> _controller = Completer();

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  Future<void> _selectCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;

    final currentLocation = await Location().getLocation();
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 17,
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.my_location,
            color: Colors.blue,
          ),
          backgroundColor: Colors.white,
          onPressed: () {
            _selectCurrentLocation();
          },
        ),
        appBar: AppBar(
          title: Text('Your Map'),
          actions: <Widget>[
            if (widget.isSelecting)
              IconButton(
                icon: Icon(Icons.check),
                onPressed: _pickedLocation == null
                    ? null
                    : () {
                        Navigator.of(context).pop(_pickedLocation);
                      },
              )
          ],
        ),
        body: Stack(
          overflow: Overflow.clip,
          children: <Widget>[
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.initialLocation.latitude,
                    widget.initialLocation.longitude,
                  ),
                  zoom: widget.zoom),
              onTap: widget.isSelecting ? _selectLocation : null,
              markers: (_pickedLocation == null && widget.isSelecting)
                  ? null
                  : {
                      Marker(
                        markerId: MarkerId('m1'),
                        position: _pickedLocation ??
                            LatLng(
                              widget.initialLocation.latitude,
                              widget.initialLocation.longitude,
                            ),
                      ),
                    },
            ),
            if(widget.isSelecting)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SearchMapPlaceWidget(
                  apiKey: 'AIzaSyCn_usNZdD8rJKPCFqAu4gl0lvNUwXXky4',
                  onSelected: (place) {
                    place.geolocation.then((geolocation){
                      _selectLocation(geolocation.coordinates);
                      _controller.future.then((future){
                        GoogleMapController controller = future;
                        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                          target: geolocation.coordinates,
                          zoom: widget.zoom,
                        )));
                      });
                    });
                  },
                  ),
            ),
          ],
        ));
  }
}
