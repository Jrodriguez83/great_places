import 'dart:io';

import 'package:flutter/Material.dart';

import '../models/place.dart';
import '../helpers/db_helper.dart';
import '../helpers/location_helper.dart';

class GreatPlaces with ChangeNotifier {
  var _filter = false;
  var _contains = '';

  List<Place> _items = [];

  List<Place> get filteredItems {
    if (_filter == true) {
      return [..._items.reversed];
    } else {
      return [..._items];
    }
  }

  // set contains(String contains) {
  //   _contains = contains;
  // }

  void searchItems(String contains){
    _contains = contains;
    notifyListeners();
  }

  List<Place> get items {
    if(_contains == ''){
      return[...filteredItems];
    }else{
    return [...filteredItems.where((test) => test.title.toLowerCase().contains(_contains))];
    }
  }

  void changeFilter() {
    _filter = !_filter;
    notifyListeners();
  }

  Place itemById(String id) {
    return _items.firstWhere((test) => test.id == id);
  }

  Future<void> addPlace(
      String title, File image, PlaceLocation location) async {
    final address = await LocationHelper.getPlaceAddress(
        location.latitude, location.longitude);
    final fullLocation = PlaceLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      address: address,
    );

    final newPlace = Place(
      id: DateTime.now().toString(),
      title: title,
      image: image,
      location: fullLocation,
    );

    _items.add(newPlace);
    notifyListeners();
    DBHelper.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'loc_lat': newPlace.location.latitude,
      'loc_lng': newPlace.location.longitude,
      'address': newPlace.location.address,
    });
  }

  Future<void> removeData(String id) async {
    await DBHelper.delete('user_places', id);
    _items.removeWhere((place) => place.id == id);
    notifyListeners();
  }

  Future<void> fetchAndSetData() async {
    final dataList = await DBHelper.fetchData('user_places');
    _items = dataList
        .map((items) => Place(
              id: items['id'],
              title: items['title'],
              image: File(items['image']),
              location: PlaceLocation(
                latitude: items['loc_lat'],
                longitude: items['loc_lng'],
                address: items['address'],
              ),
            ))
        .toList();
    notifyListeners();
  }
}
