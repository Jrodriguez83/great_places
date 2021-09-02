import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../widets/image_input.dart';
import '../provider/great_places.dart';
import '../widets/location_input.dart';

class AddPlaceScreen extends StatefulWidget {
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  String _title;
  File _pickedImage;
  PlaceLocation _pickedLocation;
  final _formKey = GlobalKey<FormState>();

  void _selectImage(File pickedImage) {
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  void _selectedLocation(double lat, double lng) {
    setState(() {
      _pickedLocation = PlaceLocation(latitude: lat, longitude: lng);
    });
  }

  void _savePlace() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    if (_pickedImage == null || _pickedLocation == null) {
      return;
    }
    _formKey.currentState.save();
    Provider.of<GreatPlaces>(context, listen: false)
        .addPlace(_title, _pickedImage, _pickedLocation);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add a New Place'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(labelText:_pickedImage==null? 'Title (Select a picture first)' :'Title',),
                          
                          enabled: _pickedImage == null ? false : true,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Title must not be empty';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _title = value;
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ImageInput(_selectImage),
                        SizedBox(
                          height: 10,
                        ),
                        LocationInput(_selectedLocation),
                      ],
                    ),
                  ),
                ),
              ),
              RaisedButton.icon(
                elevation: 0,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                color: Theme.of(context).accentColor,
                icon: Icon(Icons.add),
                label: Text((_pickedImage == null || _pickedLocation == null)
                    ? '(Places can\'t be edited after being added)'
                    : 'Add place'),
                onPressed: (_pickedImage == null || _pickedLocation == null)
                    ? null
                    : _savePlace,
              )
            ],
          ),
        ));
  }
}
