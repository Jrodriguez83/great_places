import 'dart:async';

import 'package:flutter/material.dart';
import 'package:great_places/models/place.dart';
import 'package:provider/provider.dart';

import 'map_screen.dart';
import '../provider/great_places.dart';

class PlaceDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context).settings.arguments;
    final places = Provider.of<GreatPlaces>(context, listen: false);
    final selectedPlace = places.itemById(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedPlace.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: Text('Are you sure?'),
                        content: Text(
                            '${selectedPlace.title} will be deleted. Are you sure to continue?'),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacementNamed('/');
                              places.removeData(id);
                            },
                            child: Text('Yes'),
                          ),
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('No'))
                        ],
                      ));
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          ImageContainer(id: id, selectedPlace: selectedPlace),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            selectedPlace.location.address,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          FlatButton(
            child: Text('View on Map'),
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (ctx) => MapScreen(
                        initialLocation: selectedPlace.location,
                        zoom: 20,
                      )));
            },
          )
        ],
      ),
    );
  }
}

class ImageContainer extends StatefulWidget {
  const ImageContainer({
    Key key,
    @required this.id,
    @required this.selectedPlace,
  }) : super(key: key);

  final Object id;
  final Place selectedPlace;

  @override
  _ImageContainerState createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> {
  var _expanded = false;
  var _fitSize = BoxFit.cover;

  void _changeBoxfit() {
    if (_fitSize == BoxFit.cover) {
      setState(() {
        _fitSize = BoxFit.contain;
      });
    } else {
      setState(() {
        _fitSize = BoxFit.cover;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
        Timer(Duration(milliseconds: _fitSize == BoxFit.cover ? 300 : 0),
            _changeBoxfit);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _expanded
            ? MediaQuery.of(context).size.height * 0.70
            : MediaQuery.of(context).size.height * 0.3,
        width: double.infinity,
        child: Hero(
          tag: widget.id,
          child: Image.file(
            widget.selectedPlace.image,
            fit: _fitSize,
          ),
        ),
      ),
    );
  }
}
