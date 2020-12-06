import 'dart:async';
import 'dart:math';
import 'package:tuple/tuple.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/distance.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as location_manager;
//import 'place_detail.dart';

class GeoQueryResult {
  String address;
  num distance;
  GeoQueryResult(String address, num distance) {
    this.address = address;
    this.distance = distance;
  }
}

class GeoService {
  static const kGoogleApiKey = 'AIzaSyAqaYsTHlHvfbLJO-3X5qpfLCo9Wa793OI';
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  final GoogleDistanceMatrix _distance =
      GoogleDistanceMatrix(apiKey: kGoogleApiKey);
  // final GoogleMapsGeocoding _geocoding =
  //     GoogleMapsGeocoding(apiKey: kGoogleApiKey);
  final location_manager.Location _location = location_manager.Location();
  //GoogleMapsGeolocation _geolocation = GoogleMapsGeolocation(apiKey:kGoogleApiKey )

  // check geolocation service on the device
  Future<bool> _checkLocationStausAndService() async {
    bool _serviceEnabled;
    location_manager.PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == location_manager.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != location_manager.PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  //Format addresses eliminate unnecessary information
  String _formatAddress(String rawAddr) {
    var list = rawAddr.split(',');
    var count = list.length - 2;
    var formatedStr = '';
    for (var i = 0; i < count; ++i) {
      formatedStr += (list[i] + ' ');
    }
    return formatedStr;
  }

  num roundDistance(num val, int places) {
    var mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  // Get the current long lat from device gps
  Future<Location> _getCurrentLocation() async {
    var serviceCheck = await _checkLocationStausAndService();
    if (!serviceCheck) {
      print('No access to location');
      throw ('No access to location');
    }

    print('Before calling getLocation()');

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return Location(position.latitude, position.longitude);
  }

  //TODO: implemnt Distance calculation between two PlaceId
  // Future<num> calculateDistanceStartEnd(
  //     String startPlaceID, String endPlaceID) {}

  // TODO: calculate all distance information with one search
  //Calculate the distance from current Position and a given placeId
  Future<GeoQueryResult> QueryDistanceCur(String placeID) async {
    print("QueryDistanceCurEnd Called");

    List<Location> curLocation = [
      await _getCurrentLocation().catchError((onError) {
        print("2:" + onError.toString());
      }).whenComplete(() => print("_getCurrentLocation completed " + placeID))
    ];

    PlaceDetails endPlaceDetail =
        await getPlaceDetailById(placeID).catchError((onError) {
      print("1:" + onError.toString());
    }).whenComplete(() => print("getPlaceDetailbyid completed " + placeID));

    List<Location> endLocation = [endPlaceDetail.geometry.location];

    DistanceResponse response = await _distance
        .distanceWithLocation(curLocation, endLocation)
        .catchError((onError) {
      print("3:" + onError.toString());
    });

    String endAddress = response.destinationAddress[0];
    var endDistance =
        response.results[0].elements[0].distance.value * 0.000621371;

    //endDistance = endDistance * 0.000621371;
    endDistance = roundDistance(endDistance, 2);

    return GeoQueryResult(_formatAddress(endAddress), endDistance);
  }

  // Get detail of the place with PlaceID
  Future<PlaceDetails> getPlaceDetailById(String placeID) async {
    PlacesDetailsResponse response =
        await _places.getDetailsByPlaceId(placeID).catchError((e) {
      print("getPlaceDetailbyid:" + e);
    }).whenComplete(() => print("getDetailsByPlaceId completed: " + placeID));

    if (response.status != "OK") {
      throw (response.errorMessage);
    } else {
      return response.result;
    }
  }

  Future<String> getAddrByID(String placeID) async {
    var placeDetail = await getPlaceDetailById(placeID);
    return _formatAddress(placeDetail.formattedAddress);
  }

  // Address autofill, and return a pair of address and Placeid
  Future<Tuple2<String, String>> addressAutoFill(BuildContext context) async {
    try {
      Prediction p = await PlacesAutocomplete.show(
          context: context,
          apiKey: kGoogleApiKey,
          mode: Mode.overlay,
          language: 'en',
          components: [
            Component(Component.country, 'us') //FIXME: Use us instead?
          ]);
      if (p != null) {
        return Tuple2<String, String>(p.description, p.placeId);
      }
    } catch (e) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Google Web Service error'),
              content: Text(e.toString()),
              actions: <Widget>[
                // usually buttons at the bottom of the diaprint
                FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }
}
