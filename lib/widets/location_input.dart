import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/location_helper.dart';
import '../screens/map_screen.dart';

class LocationInput extends StatefulWidget {
  final Function selectedLocation;
  LocationInput(this.selectedLocation);
  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl;
  double _zoom = 16;

  void _showPreviewImage(double lat, double lng){
    setState(() {
      _previewImageUrl = LocationHelper.generateLocationPreviewImage(
          latitude: lat,
          longitude: lng,
          zoom: _zoom);
    });
  }

  Future<void> _getCurrentLocation() async {
    final locationData = await Location().getLocation();

    _showPreviewImage(locationData.latitude, locationData.longitude);

    widget.selectedLocation(locationData.latitude, locationData.longitude);
  }

  Future<void> _selectOnMap() async {
    final LatLng selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          isSelecting: true,
          zoom: _zoom,
        ),
      ),
    );
    if(selectedLocation == null){
      return;
    }
    widget.selectedLocation(selectedLocation.latitude, selectedLocation.longitude);
    _showPreviewImage(selectedLocation.latitude, selectedLocation.latitude);

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration:
              BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          child: _previewImageUrl == null
              ? Text(
                  'No location chosen',
                  textAlign: TextAlign.center,
                )
              : Image.network(
                    _previewImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Current Location'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _getCurrentLocation,
            ),
            FlatButton.icon(
              icon: Icon(Icons.map),
              label: Text('Select on Map'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _selectOnMap,
            )
          ],
        )
      ],
    );
  }
}
